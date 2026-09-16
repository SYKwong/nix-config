{ pkgs, ... }:

let
  nixosCacheWarm = pkgs.writeShellApplication {
    name = "nixos-cache-warm";

    runtimeInputs = with pkgs; [
      coreutils
      git
      nix
      procps
    ];

    text = ''
      set -euo pipefail

      is_gaming() {
        if command -v gamemoded >/dev/null 2>&1; then
          if gamemoded -s 2>/dev/null | grep -q "is active"; then
            return 0
          fi
        fi

        if pgrep -x "gamescope|wineserver|wine|wine64-preloader|retroarch|dolphin-emu|rpcs3|ryujinx" >/dev/null 2>&1; then
          return 0
        fi

        return 1
      }

      if is_gaming; then
        echo "Active gaming session detected; skipping cache warming."
        exit 0
      fi

      flake="$HOME/nix-config"
      cd "$flake"

      default_branch=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo "origin/main")
      default_branch="''${default_branch#origin/}"

      echo "Fetching latest $default_branch from origin..."
      if ! git fetch origin "$default_branch"; then
        echo "Warning: git fetch failed, proceeding with local cached ref..."
      fi

      if ! target_rev=$(git rev-parse "origin/$default_branch" 2>/dev/null); then
        target_rev=$(git rev-parse HEAD)
      fi

      stamp_file="''${XDG_CACHE_HOME:-$HOME/.cache}/nixos-cache-warm/last_warmed_rev"
      if [ -f "$stamp_file" ] && [ "$(cat "$stamp_file")" = "$target_rev" ]; then
        echo "Cache is already warmed for revision $target_rev. Exiting."
        exit 0
      fi

      echo "Warming cache for revision $target_rev..."

      hosts=$(
        nix eval \
          --raw \
          "git+file://$flake?rev=$target_rev#nixosConfigurations" \
          --apply 'configs: builtins.concatStringsSep "\n" (builtins.attrNames configs)'
      )

      build_failed=false
      while IFS= read -r host; do
        [ -n "$host" ] || continue

        if is_gaming; then
          echo "Gaming session started; aborting cache warming."
          exit 0
        fi

        echo "Warming cache for $host..."

        if ! nix build \
          --max-jobs 4 \
          --cores 4 \
          --no-link \
          "git+file://$flake?rev=$target_rev#nixosConfigurations.$host.config.system.build.toplevel"; then
          echo "Warning: Failed to build $host"
          build_failed=true
        fi
      done <<< "$hosts"

      if [ "$build_failed" = true ]; then
        echo "One or more configurations failed to build. Stamp file will not be updated."
        exit 1
      fi

      mkdir -p "$(dirname "$stamp_file")"
      echo "$target_rev" > "$stamp_file"
      echo "Successfully warmed cache for revision $target_rev."
    '';
  };
in
{
  systemd.user.services.nixos-cache-warm = {
    Unit = {
      Description = "Warm Nix cache for all NixOS configurations";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${nixosCacheWarm}/bin/nixos-cache-warm";
      Nice = 19;
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
  };

  systemd.user.timers.nixos-cache-warm = {
    Unit = {
      Description = "Trigger Nix cache warming periodically overnight";
    };

    Timer = {
      OnCalendar = "*-*-* 02..08:00:00";
      Persistent = false;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
