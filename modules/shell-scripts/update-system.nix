{ pkgs, hostname, username, config_path, ... }:

pkgs.writeShellApplication {
  name = "update-system";

  runtimeInputs = with pkgs; [
    git
    nixos-rebuild
    procps
    waybar
    coreutils
  ];

  text = ''
    REPO="${config_path}"

    cd "$REPO"

    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    echo "--- Switching to main and pulling changes ---"

    STASH_RESULT=$(git stash push -m "temp-update-stash" || true)

    git switch main
    git pull

    echo "--- Running NixOS Rebuild ---"

    if sudo nixos-rebuild switch --flake "$REPO#${hostname}"; then
      echo "Live switch succeeded."
    else
      echo "Live switch failed. Making a new boot entry instead."

      if sudo nixos-rebuild boot --flake "$REPO#${hostname}"; then
        echo "Boot entry created successfully."
      else
        echo "Failed to build configuration."
        exit 1
      fi
    fi

    echo "--- Returning to $CURRENT_BRANCH ---"

    git switch "$CURRENT_BRANCH"

    if [[ "$STASH_RESULT" != "No local changes to save" ]]; then
      echo "--- Restoring stashed changes ---"
      git stash pop
    fi

    pkill -RTMIN+7 waybar || true

    read -n 1 -s -r -p "Press any key to exit..."
    echo
  '';
}
