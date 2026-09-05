{
  config,
  pkgs,
  username,
  ...
}:

let
  networkShare = import ../config/networkshare-config.nix { inherit username; };
  inherit (networkShare) mountPath nasAddress shareName;

  checkNas = pkgs.writeShellApplication {
    name = "check-nas-cifs";

    runtimeInputs = [
      pkgs.netcat
      pkgs.systemd
      pkgs.util-linux
    ];

    text = ''
      NAS="${nasAddress}"
      MOUNT="${mountPath}"

      MOUNT_UNIT="$(systemd-escape --path --suffix=mount "$MOUNT")"

      if nc -z -w 1 "$NAS" 445 >/dev/null 2>&1; then
        if ! systemctl is-active --quiet "$MOUNT_UNIT"; then
          echo "SMB server $NAS:445 is reachable; mounting $MOUNT"
          systemctl start "$MOUNT_UNIT"
        fi

        exit 0
      fi

      echo "SMB server $NAS:445 is unreachable"

      if systemctl is-active --quiet "$MOUNT_UNIT"; then
        echo "NAS unreachable; lazy-unmounting $MOUNT"
        umount -l "$MOUNT"
      fi
    '';
  };
in
{
  fileSystems.${mountPath} = {
    fsType = "cifs";
    device = "//${nasAddress}/${shareName}";

    options = [
      "credentials=${config.age.secrets.smb-credentials.path}"

      "vers=3.0"
      "noperm"
      "_netdev"
      "noauto"

      "uid=${username}"
      "gid=users"
      "file_mode=0664"
      "dir_mode=0775"

      "x-systemd.mount-timeout=10s"
    ];
  };

  systemd.services.check-nas-cifs = {
    description = "Check CIFS NAS reachability";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${checkNas}/bin/check-nas-cifs";
    };
  };

  systemd.timers.check-nas-cifs = {
    description = "Periodically check CIFS NAS reachability";

    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "30s";
      AccuracySec = "5s";
    };
  };

  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "check-nas-cifs-dispatcher" ''
        case "$2" in
          up|down|dhcp4-change|dhcp6-change)
            ${pkgs.systemd}/bin/systemctl start check-nas-cifs.service
            ;;
        esac
      '';

      type = "basic";
    }
  ];
}
