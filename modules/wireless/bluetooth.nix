{
  config,
  lib,
  ...
}:

let
  cfg = config.custom.wireless.bluetooth;
in
{
  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      inherit (cfg) powerOnBoot;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };

    services.pipewire = {
      extraConfig.pipewire-pulse."99-switch-on-connect" = {
        "pulse.cmd" = [
          {
            cmd = "load-module";
            args = "module-switch-on-connect";
          }
        ];
      };

      wireplumber.extraConfig."10-bluetooth-policy" = {
        "monitor.bluez.rules" = [
          {
            matches = [
              {
                "node.name" = "~bluez_output.*";
              }
            ];
            actions = {
              update-props = {
                "priority.driver" = 1050;
                "priority.session" = 1050;
              };
            };
          }
        ];
      };
    };
  };
}
