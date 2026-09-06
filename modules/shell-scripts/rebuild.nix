{
  pkgs,
  hostname,
  config_path,
  ...
}:

pkgs.writeShellApplication {
  name = "rebuild";

  runtimeInputs = [
    pkgs.binutils
    pkgs.coreutils
    pkgs.gawk
    pkgs.gnugrep
    pkgs.nixos-rebuild
    pkgs.systemd
  ];

  text = ''
    REPO="${config_path}"
    HOSTNAME="${hostname}"

    if ! sudo nixos-rebuild boot --flake "$REPO#$HOSTNAME"; then
        echo "Critical Error: Failed to build configuration."
        exit 1
    fi

    echo "Boot entry created successfully."

    echo "--- Activating configuration live ---"
    if sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch; then
        echo "Live switch succeeded."
    else
        echo "Live switch failed. Boot entry is saved and changes will apply on next reboot."
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
            reboot
        fi
    fi
  '';
}
