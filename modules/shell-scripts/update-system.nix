{
  pkgs,
  config_path,
  ...
}:

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
    REPO=${config_path}

    cd "$REPO"

    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    echo "--- Switching to main and pulling changes ---"

    STASH_RESULT=$(git stash push -m "temp-update-stash" || true)

    git switch main
    git pull

    echo "--- Running NixOS Rebuild ---"

    rebuild

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
