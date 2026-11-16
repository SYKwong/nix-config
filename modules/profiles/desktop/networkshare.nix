{
  config,
  username,
  ...
}:

let
  networkShare = import ../../config/networkshare-config.nix {
    inherit config username;
  };
in
{
  fileSystems = networkShare.mkCifsFileSystem [ "x-systemd.automount" ];
}
