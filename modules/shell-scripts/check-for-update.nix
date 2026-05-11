{ pkgs, hostname, username, ... }:

let
  config_path = "/home/${username}/nix-config";

  update-available = pkgs.writeShellScriptBin "update-available" ''
    repo="${config_path}"
    local_hash=$(git -C "$config_path" rev-parse main 2>/dev/null)
    remote_hash=$(git -C "$config_path" ls-remote origin -h refs/heads/main 2>/dev/null | awk '{print $1}')

    if [[ -n "$remote_hash" && "$local_hash" != "$remote_hash" ]]; then
      echo "update available $remote_hash"
      exit 0
    else
      echo "no update at the moment"
      exit 1
    fi
  '';

  update-system = pkgs.writeShellScriptBin "update-system" ''
    set -e
    REPO="${config_path}"
    cd "$REPO"

    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    echo "--- Switching to main and pulling changes ---"
    STASH_RESULT=$(git stash push -m "temp-update-stash")
    git switch main
    git pull
    
    echo "---  Running NixOS Rebuild ---"
    sudo nixos-rebuild switch --flake ~/nix-config/#${hostname} 
    if [ $? -eq 1 ]; then
      echo "Live switch failed. Making a new boot entry instead."
      sudo nixos-rebuild boot --flake ~/nix-config/#${hostname} 
      if [ $? -eq 1 ]; then
        echo "Fail to build the confiuration. Please check for any errors in the config."
      fi
    fi

    echo "--- Returning to $CURRENT_BRANCH ---"
    git switch "$CURRENT_BRANCH"

    if [[ "$STASH_RESULT" != "No local changes to save" ]]; then
      echo "--- Restoring stashed changes ---"
      git stash pop
    fi

    pkill -RTMIN+7 waybar

    read -n 1 -s -r -p "Press any key to exit..."
    echo "" # Adds a newline so the next terminal prompt starts on a fresh line
    exit 0
  '';
in
{
  environment.systemPackages = [ 
    update-available 
    update-system
  ];
}
