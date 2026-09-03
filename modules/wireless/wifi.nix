{
  config,
  lib,
  ...
}:

let
  cfg = config.custom.wireless.wifi;
in
{
  config = lib.mkIf cfg.enable {
    networking = {
      wireless.iwd.enable = true;
      networkmanager.wifi = {
        backend = "iwd";
        powersave = true;
      };
    };
  };
}
