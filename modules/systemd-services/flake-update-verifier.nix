{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.systemd-services.flake-update-verifier;

  formatPackageDiffJq = pkgs.writeText "format-package-diff.jq" ''
    def dedup_versions:
      . as $all
      | map(select(
          . as $cur
          | ($all | any(
              . as $other
              | $other != $cur
              and $other.kind == $cur.kind
              and (($other.old.name // "") == "" or (($cur.old.name // "") | startswith(($other.old.name // "") + "-")))
              and (($other.new.name // "") == "" or (($cur.new.name // "") | startswith(($other.new.name // "") + "-")))
            )) | not
        ));

    def format_version_entry:
      if .kind == "changed" then "`\(.old.name)` -> `\(.new.name)`"
      elif .kind == "added" then "`\(.new.name)` (added)"
      elif .kind == "removed" then "`\(.old.name)` (removed)"
      else empty
      end;

    def fmt_bytes:
      (if . < 0 then "-" else "" end) as $sign
      | (if . < 0 then -. else . end) as $n
      | if $n >= 1073741824 then "\($sign)\(($n / 1073741824 * 10 | round) / 10) GiB"
        elif $n >= 1048576 then "\($sign)\(($n / 1048576 * 100 | round) / 100) MiB"
        elif $n >= 1024 then "\($sign)\(($n / 1024 * 10 | round) / 10) KiB"
        else "\($sign)\($n) B"
        end;

    def fmt_delta:
      if . > 0 then "+\(fmt_bytes)"
      elif . < 0 then fmt_bytes
      else "0 B"
      end;

    def normalize_host:
      .host as $host
      | .diff
      | {
          host: $host,
          size_new: .size_new,
          size_delta: (.size_new - .size_old),
          paths_added: .paths.added,
          paths_removed: .paths.removed,
          packages: (
            .diffs
            | map(
                select(.kind == "version" and .name != ("nixos-system-" + $host))
                | {
                    name: .name,
                    versions: (.versions | dedup_versions | map(format_version_entry) | join(", "))
                  }
              )
            | sort_by(.name)
          )
        };

    def render_table:
      "| Package | Version |\n| :--- | :--- |\n"
      + (map("| `\(.name)` | \(.versions) |") | join("\n"));

    def pkg_key: "\(.name)|\(.versions)";

    map(normalize_host) as $hosts
    | ($hosts | length) as $host_count
    | (
        if $host_count > 1 then
          ($hosts | map(.packages | map(pkg_key) | unique) | add // [] | group_by(.) | map(select(length == $host_count) | .[0]))
        else
          []
        end
      ) as $common_keys
    | (
        if ($common_keys | length) > 0 then
          $hosts[0].packages | map(select((pkg_key) as $k | $common_keys | index($k) != null))
        else
          []
        end
      ) as $common_pkgs
    | (
        $hosts | map(
          . + {
            unique_packages: (.packages | map(select((pkg_key) as $k | $common_keys | index($k) == null)))
          }
        )
      ) as $per_host
    | "### Package updates (`\($base)` -> `\($target)`)\n\n"
      + (
          if $host_count > 1 then
            "#### Common (all \($host_count) hosts - \($common_pkgs | length) changed)\n\n"
            + (
                if ($common_pkgs | length) == 0 then
                  "_No common package changes._\n\n"
                elif ($common_pkgs | length) > 20 then
                  "<details>\n<summary>Show \($common_pkgs | length) common package updates</summary>\n\n"
                  + ($common_pkgs | render_table)
                  + "\n\n</details>\n\n"
                else
                  ($common_pkgs | render_table) + "\n\n"
                end
              )
          else
            ""
          end
        )
      + "#### Per-Device\n\n"
      + "| Host | Closure Size | Paths | Host-Specific Changes |\n| :--- | :--- | :--- | :--- |\n"
      + (
          $per_host
          | map(
              "| `\(.host)` | \(.size_new | fmt_bytes) (\(.size_delta | fmt_delta)) | +\(.paths_added) / -\(.paths_removed) | "
              + (
                  if (.unique_packages | length) == 0 then
                    if $host_count > 1 then "None (common only)" else "None" end
                  else
                    "\(.unique_packages | length) changed"
                  end
                )
              + " |"
            )
          | join("\n")
        )
      + (
          $per_host
          | map(
              select((.unique_packages | length) > 0)
              | "\n\n<details>\n<summary><code>\(.host)</code> - \(.unique_packages | length) host-specific package changes</summary>\n\n"
                + (.unique_packages | render_table)
                + "\n\n</details>"
            )
          | join("")
        )
  '';

  flakeUpdateVerifier = pkgs.writeShellApplication {
    name = "flake-update-verifier";

    runtimeInputs = with pkgs; [
      coreutils
      dix
      git
      glab
      gnused
      jq
      nix
      openssh
    ];

    text = ''
      force=false
      for arg in "$@"; do
        if [ "$arg" = "--force" ] || [ "$arg" = "-f" ]; then
          force=true
        fi
      done

      export SSH_AUTH_SOCK="''${SSH_AUTH_SOCK:-/run/user/$(id -u)/gcr/ssh}"

      flake="''${HOME}/nix-config"
      if [ ! -d "''${flake}/.git" ]; then
        echo "Flake repository not found at ''${flake}. Skipping."
        exit 0
      fi
      cd "''${flake}"

      if ! glab auth status >/dev/null 2>&1; then
        echo "glab is not authenticated; skipping flake update verification."
        exit 0
      fi

      mr_json=$(glab mr list --label dependencies --output json --jq '.[0] // empty' 2>/dev/null || true)
      if [ -z "$mr_json" ]; then
        echo "No open dependency update MRs found. Nothing to verify."
        exit 0
      fi

      mr_iid=$(echo "$mr_json" | jq -r '.iid')
      source_branch=$(echo "$mr_json" | jq -r '.source_branch')
      mr_description=$(echo "$mr_json" | jq -r '.description // ""')

      echo "Fetching main and $source_branch from origin..."
      if ! git fetch origin main "$source_branch"; then
        echo "Failed to fetch main and $source_branch from origin. Skipping."
        exit 1
      fi

      if ! git merge-base --is-ancestor origin/main "origin/$source_branch"; then
        echo "MR !$mr_iid ($source_branch) is behind origin/main. Rebasing onto main..."
        if ! glab mr rebase "$mr_iid" --skip-ci; then
          echo "Failed to rebase MR !$mr_iid onto main."
          exit 1
        fi
        if ! git fetch origin "$source_branch"; then
          echo "Failed to fetch rebased $source_branch from origin. Skipping."
          exit 1
        fi
      fi

      base_sha=$(git rev-parse origin/main)
      target_sha=$(git rev-parse "origin/$source_branch")

      stamp_file="''${XDG_CACHE_HOME:-$HOME/.cache}/flake-update-verifier/last_failed_sha"
      if [ "$force" = false ] && [ -f "$stamp_file" ] && [ "$(cat "$stamp_file")" = "$target_sha" ]; then
        echo "Revision $target_sha on MR !$mr_iid previously failed verification. Skipping until updated."
        exit 0
      fi

      echo "Found open dependency MR !$mr_iid ($source_branch) at SHA $target_sha."

      if [ "$(git rev-parse --is-shallow-repository 2>/dev/null)" = "true" ]; then
        echo "Repository is shallow; unshallowing from origin..."
        git fetch --unshallow origin 2>/dev/null || true
      fi

      hosts=$(
        nix eval \
          --raw \
          "git+file://$flake?rev=$target_sha&shallow=1#nixosConfigurations" \
          --apply 'configs: builtins.concatStringsSep "\n" (builtins.filter (name: name != "installer") (builtins.attrNames configs))'
      )

      host_list=()
      targets=()
      while IFS= read -r host; do
        [ -n "$host" ] || continue
        host_list+=("$host")
        targets+=("git+file://$flake?rev=$target_sha&shallow=1#nixosConfigurations.$host.config.system.build.toplevel")
      done <<< "$hosts"

      if [ "''${#targets[@]}" -eq 0 ]; then
        echo "No host configurations found to verify. Skipping."
        exit 0
      fi

      echo "Verifying build for all hosts on revision $target_sha:"
      echo "$hosts"

      build_log=$(mktemp)
      trap 'rm -f "$build_log"' EXIT

      if ! nix build --no-link "''${targets[@]}" 2>&1 | tee "$build_log" >&2; then
        echo "Build failed for one or more hosts on revision $target_sha."

        error_excerpt=$(sed -n '/^error:/,$p' "$build_log" | head -n 60)
        if [ -z "$error_excerpt" ]; then
          error_excerpt=$(tail -n 40 "$build_log")
        fi

        note_body=$(printf "### \`flake-update-verifier\` build failed on \`%s\`\n\n\`\`\`text\n%s\n\`\`\`" "$target_sha" "$error_excerpt")
        if ! glab mr note create "$mr_iid" --resolvable=false --unique -m "$note_body"; then
          echo "Warning: failed to post failure note to MR !$mr_iid."
        fi

        if ! glab mr update "$mr_iid" --label build-error --yes; then
          echo "Warning: failed to add build-error label to MR !$mr_iid."
        fi

        echo "Verification failed for MR !$mr_iid. Storing failed SHA to prevent redundant retries."
        mkdir -p "$(dirname "$stamp_file")"
        echo "$target_sha" > "$stamp_file"
        exit 1
      fi

      update_mr_package_diff() {
        local diff_mr_iid="$1"
        local diff_base_sha="$2"
        local diff_target_sha="$3"
        local existing_description="$4"
        shift 4

        local short_base_sha short_target_sha
        short_base_sha=$(git rev-parse --short "$diff_base_sha")
        short_target_sha=$(git rev-parse --short "$diff_target_sha")

        local diff_json_dir
        diff_json_dir=$(mktemp -d)

        local diff_host old_path new_path host_json_file
        local collected_files=()

        for diff_host in "$@"; do
          new_path=$(nix build --no-link --print-out-paths \
            "git+file://$flake?rev=$diff_target_sha&shallow=1#nixosConfigurations.$diff_host.config.system.build.toplevel" 2>/dev/null || true)
          old_path=$(nix build --no-link --print-out-paths \
            "git+file://$flake?rev=$diff_base_sha&shallow=1#nixosConfigurations.$diff_host.config.system.build.toplevel" 2>/dev/null || true)

          if [ -z "$new_path" ] || [ -z "$old_path" ]; then
            echo "Warning: skipping package diff for $diff_host (could not resolve base or target closure)."
            continue
          fi

          host_json_file="$diff_json_dir/$diff_host.json"
          if dix diff --output=json "$old_path" "$new_path" \
            | jq --arg host "$diff_host" '{ host: $host, diff: . }' > "$host_json_file"; then
            collected_files+=("$host_json_file")
          else
            echo "Warning: failed to generate JSON diff for $diff_host."
            rm -f "$host_json_file"
          fi
        done

        if [ "''${#collected_files[@]}" -eq 0 ]; then
          rm -rf "$diff_json_dir"
          echo "Warning: no host package diffs generated for MR !$diff_mr_iid."
          return 0
        fi

        local diff_body
        diff_body=$(jq -rs \
          --arg base "$short_base_sha" \
          --arg target "$short_target_sha" \
          -f "${formatPackageDiffJq}" \
          "''${collected_files[@]}")
        rm -rf "$diff_json_dir"

        local marker="<!-- flake-update-verifier:package-diff -->"
        local base_description
        base_description=$(printf '%s\n' "$existing_description" | sed "/$marker/,\$d" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')

        local updated_description
        if [ -n "$base_description" ]; then
          updated_description=$(printf '%s\n\n%s\n\n%s\n' "$base_description" "$marker" "$diff_body")
        else
          updated_description=$(printf '%s\n\n%s\n' "$marker" "$diff_body")
        fi

        if ! printf '%s' "$updated_description" | glab mr update "$diff_mr_iid" --description-file - --yes; then
          echo "Warning: failed to update MR !$diff_mr_iid description with package diff."
        fi
      }

      echo "All host configurations built successfully! Updating MR !$mr_iid description with package diff and merging into main..."
      update_mr_package_diff "$mr_iid" "$base_sha" "$target_sha" "$mr_description" "''${host_list[@]}"
      glab mr update "$mr_iid" --unlabel build-error --yes >/dev/null 2>&1 || true
      glab mr merge "$mr_iid" --auto-merge=false --squash --yes --remove-source-branch
      echo "Successfully merged verified MR !$mr_iid into main."

      rm -f "$stamp_file"
    '';
  };
in
{
  options.custom.systemd-services.flake-update-verifier = {
    enable = lib.mkEnableOption "automated flake update verification and auto-merge service";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      flakeUpdateVerifier
    ];

    systemd.user.services.flake-update-verifier = {
      description = "Verify open dependency flake update merge requests and auto-merge if builds pass";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${flakeUpdateVerifier}/bin/flake-update-verifier";
        Nice = 19;
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        Environment = [
          "SSH_AUTH_SOCK=%t/gcr/ssh"
        ];
      };
    };

    systemd.user.timers.flake-update-verifier = {
      description = "Scheduled verification of open flake update merge requests";
      timerConfig = {
        OnCalendar = "*-*-* 03..07:00:00";
        Persistent = false;
        RandomizedDelaySec = "15m";
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
