{
  config,
  username,
}:

let
  mountPath = "/home/${username}/data";
  nasAddress = "192.168.50.32";
  shareName = "data";
in
{
  inherit
    mountPath
    nasAddress
    shareName
    ;

  mkCifsFileSystem = extraOptions: {
    ${mountPath} = {
      fsType = "cifs";
      device = "//${nasAddress}/${shareName}";

      options = [
        "credentials=${config.age.secrets.smb-credentials.path}"

        "vers=3.0"
        "noperm"
        "_netdev"

        "uid=${username}"
        "gid=users"
        "file_mode=0664"
        "dir_mode=0775"

        "x-systemd.mount-timeout=10s"
      ]
      ++ extraOptions;
    };
  };
}
