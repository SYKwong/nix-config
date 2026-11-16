{
  config,
  lib,
  username,
  ...
}:

let
  cfg = config.custom.sunshine;
in
{
  options.custom.sunshine = {
    enable = lib.mkEnableOption "Sunshine game and desktop streaming server" // {
      default = true;
    };

    autoStart = lib.mkEnableOption "starting Sunshine automatically upon graphical session login" // {
      default = true;
    };

    openFirewall = lib.mkEnableOption "opening required firewall ports for Sunshine streaming" // {
      default = true;
    };

    capSysAdmin =
      lib.mkEnableOption "granting CAP_SYS_ADMIN capabilities to the Sunshine binary for KMS/DRM capture"
      // {
        default = true;
      };

    tabletDisplay = {
      enable = lib.mkEnableOption "automated zero-touch Tablet Display application in Sunshine" // {
        default = true;
      };

      scale = lib.mkOption {
        type = lib.types.str;
        default = "1.6";
        description = "Display scaling factor for the tablet virtual monitor in Hyprland.";
      };

      idleTimeout = lib.mkOption {
        type = lib.types.int;
        default = 900;
        description = "Idle timeout in seconds before automatically terminating paused sessions and removing the virtual display (0 to disable).";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      inherit (cfg)
        autoStart
        openFirewall
        capSysAdmin
        ;

      settings = {
        capture = "wlr";
      }
      // lib.optionalAttrs cfg.tabletDisplay.enable {
        output_name = "HEADLESS-1";
      };

      applications = lib.mkIf cfg.tabletDisplay.enable {
        env = {
          PATH = "$(PATH)";
        };
        apps =
          let
            mkVirtualDisplayApp = name: {
              inherit name;
              image-path = "desktop.png";
              prep-cmd = [
                {
                  do = "/run/current-system/sw/bin/hypr-virtual-monitor start HEADLESS-1 ${cfg.tabletDisplay.scale}";
                  undo = "/run/current-system/sw/bin/hypr-virtual-monitor stop HEADLESS-1";
                }
              ];
              exclude-global-prep-cmd = "false";
              auto-detach = "true";
            };
          in
          map mkVirtualDisplayApp [
            "Tablet Display"
            "Desktop"
          ];
      };
    };

    # Grant user permission to simulate virtual input devices via uinput and access video nodes
    users.users."${username}".extraGroups = [
      "input"
      "uinput"
      "video"
    ];

    # Prevent USB tethering (Android tablet) from hijacking the PC's default internet gateway
    networking.networkmanager.settings = {
      "connection-usb-tether" = {
        "match-device" = "interface-name:usb*,interface-name:en*u*";
        "ipv4.never-default" = "true";
        "ipv4.route-metric" = "1000";
      };
    };

    # Automatically kill paused/idle sessions after timeout and restore workspaces (started on-demand by prep-cmd)
    systemd.user.services.sunshine-watchdog =
      lib.mkIf (cfg.tabletDisplay.enable && cfg.tabletDisplay.idleTimeout > 0)
        {
          description = "Sunshine idle session and virtual monitor watchdog";
          partOf = [ "graphical-session.target" ];
          after = [
            "graphical-session.target"
            "sunshine.service"
          ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "/run/current-system/sw/bin/hypr-virtual-monitor watchdog HEADLESS-1 ${toString cfg.tabletDisplay.idleTimeout}";
            Restart = "no";
          };
        };
  };
}
