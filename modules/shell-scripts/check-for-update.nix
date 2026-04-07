{ pkgs, ... }:

let
  update-available = pkgs.writeShellScriptBin "update-available" ''
    config_path="~/nix-config"
    local_hash=$(git -C "$config_path" rev-parse main 2>/dev/null)
    remote_hash=$(git -C "$config_path" ls-remote origin -h refs/heads/main | awk '{print $1}')

    if [ "$local_hash" != "$remote_hash" ]; then
      echo "update available $remote_hash"
      exit 1
    else
      exit 0
    fi
  '';

  update-system = pkgs.writeShellScriptBin "update-system" ''
    nrs 
    
    if [ $? -eq 1 ]; then
      echo "Live switch failed. Making a new boot entry instead."
      nrb
      if [ $? -eq 1 ]; then
        echo "Fail to build the confiuration. Please check for any errors in the config."
      fi
    fi

    echo "Press any key to exit..."
    read -n 1 -s -r
    exit 0
  '';
in
{
  environment.systemPackages = [ 
    update-available 
    update-system
  ];
}
