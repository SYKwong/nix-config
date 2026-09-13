{
  pkgs,
  username,
  ...
}:

let
  steamosSessionSelect = pkgs.writeShellApplication {
    name = "steamos-session-select";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.systemd
    ];
    text = ''
      target="''${1:-plasma}"
      case "$target" in
        plasma*|desktop)
          mkdir -p /etc/sddm.conf.d
          printf "[Autologin]\nSession=plasma.desktop\n" > /etc/sddm.conf.d/zz-steamos-autologin.conf
          loginctl terminate-user "$USER" || systemctl restart display-manager
          ;;
        gamescope*|steam*|game)
          rm -f /etc/sddm.conf.d/zz-steamos-autologin.conf
          loginctl terminate-user "$USER" || systemctl restart display-manager
          ;;
        *)
          echo "Unknown session target: $target" >&2
          exit 1
          ;;
      esac
    '';
  };

  returnToGamingMode = pkgs.makeDesktopItem {
    name = "Return";
    desktopName = "Return to Gaming Mode";
    comment = "Switch back to Steam Big Picture";
    exec = "${steamosSessionSelect}/bin/steamos-session-select gamescope";
    icon = "steam";
    terminal = false;
    type = "Application";
    categories = [ "System" ];
  };
in
{
  # KDE Plasma 6 Desktop Environment for handheld desktop mode (SteamOS style)
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = [
    steamosSessionSelect
    returnToGamingMode
  ];

  # Allow user in users group to manage temporary SDDM session switch without root password
  systemd = {
    tmpfiles.rules = [
      "d /etc/sddm.conf.d 0775 root users -"
      "d /home/${username}/Desktop 0755 ${username} users -"
      "L+ /home/${username}/Desktop/Return.desktop - - - - ${returnToGamingMode}/share/applications/Return.desktop"
    ];

    # Session initialization: auto-login to KDE Plasma on first boot for setup, default to Steam Gaming Mode on subsequent boots
    services.display-manager.serviceConfig.ExecStartPre = [
      "-${pkgs.writeShellScript "sddm-session-init" ''
        export PATH="${pkgs.coreutils}/bin:$PATH"
        SENTINEL="/var/lib/handheld-first-boot-done"
        CONF_DIR="/etc/sddm.conf.d"
        CONF_FILE="$CONF_DIR/zz-steamos-autologin.conf"

        if [ ! -f "$SENTINEL" ]; then
          mkdir -p "$CONF_DIR"
          printf "[Autologin]\nSession=plasma.desktop\n" > "$CONF_FILE"
          touch "$SENTINEL"
        else
          rm -f "$CONF_FILE"
        fi
      ''}"
    ];
  };
}
