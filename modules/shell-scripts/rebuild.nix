{
  pkgs,
  hostname,
  config_path,
  ...
}:

pkgs.writeShellApplication {
  name = "rebuild"; # This becomes your new command name

  runtimeInputs = [
    pkgs.coreutils
    pkgs.gnused
    pkgs.nixos-rebuild
    pkgs.nettools
  ];

  text = ''
    REPO="${config_path}"
    HOSTNAME="${hostname}"

    if sudo nixos-rebuild switch --flake "$REPO#$HOSTNAME"; then
        echo "Live switch succeeded."
    else
        echo "Live switch failed. Making a new boot entry instead..."
        
        if sudo nixos-rebuild boot --flake "$REPO#$HOSTNAME"; then
            echo "Boot entry created successfully."
        else
            echo "Critical Error: Failed to build configuration entirely."
            exit 1
        fi
    fi

    CONFIG_KERNEL=$(strings /nix/var/nix/profiles/system/kernel | grep -E '^[0-9]+\.[0-9]+' | head -n 1 | awk '{print $1}')
    RUNNING_KERNEL=$(uname -r | awk '{print $1}')

    if [ "$RUNNING_KERNEL" != "$CONFIG_KERNEL" ]; then
        echo ""
        echo "Pending reboot to apply kernel update"
        echo "Running:    $RUNNING_KERNEL"
        echo "Staged:     $CONFIG_KERNEL"
        echo ""
        
        printf "Would you like to reboot now to apply the changes? (y/N): "
        read -r reply
        if [[ "$reply" =~ ^[Yy]$ ]]; then
            sudo reboot
        fi
    fi
  '';
}
