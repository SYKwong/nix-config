{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "wallpaper-sync";

  runtimeInputs = with pkgs; [
    coreutils
    git
    openssh
  ];

  text = ''
    set -euo pipefail

    wallpaper_directory="''${HOME}/Wallpaper"

    if [ ! -d "''${wallpaper_directory}/.git" ]; then
      echo "Wallpaper repository not found at ''${wallpaper_directory}. Skipping sync."
      exit 0
    fi

    cd "''${wallpaper_directory}"

    export SSH_AUTH_SOCK="''${SSH_AUTH_SOCK:-/run/user/$(id -u)/gcr/ssh}"

    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
    remote_name="origin"

    echo "Checking connectivity to ''${remote_name}..."
    if ! git ls-remote "''${remote_name}" HEAD >/dev/null 2>&1; then
      echo "Remote ''${remote_name} is unreachable or SSH key is not loaded. Skipping sync."
      exit 0
    fi

    echo "Pulling latest changes from ''${remote_name}/''${current_branch}..."
    if ! git pull --rebase --autostash "''${remote_name}" "''${current_branch}"; then
      echo "Error: git pull --rebase encountered conflicts. Aborting rebase to preserve working state."
      git rebase --abort 2>/dev/null || true
      exit 1
    fi

    if [ -n "$(git status --porcelain)" ]; then
      echo "Local changes detected in ''${wallpaper_directory}; committing and pushing..."
      git add -A
      git commit -m "sync(wallpaper): automated sync $(date +'%Y-%m-%d %H:%M')"
      if ! git push "''${remote_name}" "''${current_branch}"; then
        echo "Warning: git push failed. Local changes remain committed and will be pushed on next sync."
        exit 1
      fi
      echo "Successfully synced and pushed wallpapers."
    else
      echo "No local changes to push. Wallpaper repository is up to date."
    fi
  '';
}
