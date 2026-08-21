{
  config,
  username,
  ...
}:

let
  networkShare = import ../config/networkshare-config.nix { inherit username; };
  inherit (networkShare) mountPath nasAddress shareName;

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

      "uid=1000"
      "gid=100"
      "file_mode=0664"
      "dir_mode=0775"

      "x-systemd.automount"
      "x-systemd.mount-timeout=10s"
    ];
  };
}
