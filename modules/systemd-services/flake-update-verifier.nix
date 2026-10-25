{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.systemd-services.flake-update-verifier;

  flakeUpdateVerifier = pkgs.writeShellApplication {
    name = "flake-update-verifier";

    runtimeInputs = with pkgs; [
      coreutils
      git
      glab
      jq
      nix
    ];

    text = ''
      set -euo pipefail

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
      target_sha=$(echo "$mr_json" | jq -r '.sha')

      stamp_file="''${XDG_CACHE_HOME:-$HOME/.cache}/flake-update-verifier/last_failed_sha"
      if [ -f "$stamp_file" ] && [ "$(cat "$stamp_file")" = "$target_sha" ]; then
        echo "Revision $target_sha on MR !$mr_iid previously failed verification. Skipping until updated."
        exit 0
      fi

      echo "Found open dependency MR !$mr_iid ($source_branch) at SHA $target_sha."
      echo "Fetching $source_branch from origin..."
      if ! git fetch origin "$source_branch"; then
        echo "Failed to fetch $source_branch from origin. Skipping."
        exit 1
      fi

      hosts=$(
        nix eval \
          --raw \
          "git+file://$flake?rev=$target_sha#nixosConfigurations" \
          --apply 'configs: builtins.concatStringsSep "\n" (builtins.attrNames configs)'
      )

      build_failed=false
      while IFS= read -r host; do
        [ -n "$host" ] || continue

        echo "Verifying build for $host on revision $target_sha..."
        if ! nix build --no-link \
          "git+file://$flake?rev=$target_sha#nixosConfigurations.$host.config.system.build.toplevel"; then
          echo "Build failed for $host on revision $target_sha."
          build_failed=true
          break
        fi
      done <<< "$hosts"

      if [ "$build_failed" = true ]; then
        echo "Verification failed for MR !$mr_iid. Storing failed SHA to prevent redundant retries."
        mkdir -p "$(dirname "$stamp_file")"
        echo "$target_sha" > "$stamp_file"
        exit 1
      fi

      echo "All host configurations built successfully! Merging MR !$mr_iid into main..."
      glab mr merge "$mr_iid" --squash --yes --remove-source-branch
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
