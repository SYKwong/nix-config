{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.cifs-utils ];

  fileSystems."/mnt/nas" = {
    fsType = "cifs";
    device = "//192.168.50.32/data";
    options = [
      "credentials=${config.age.secrets.smb-credentials.path}"

      "vers=3.0"
      "noperm"
      "_netdev"

      "uid=1000"
      "gid=100"
      "file_mode=0664"
      "dir_mode=0775"

      "x-systemd.automount"
    ];
  };
}
