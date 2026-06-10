{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.waybar ];

  systemd.user.services.waybar-update-check = {
    description = "Run hourly update check for Waybar";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.procps}/bin/pkill -SIGRTMIN+7 waybar
      '';
    };
  };

  systemd.user.timers.waybar-update-check = {
    description = "Hourly timer for Waybar update check";

    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnStartupSec = "1min";
      OnUnitActiveSec = "1h";
      Persistent = true;
      Unit = "waybar-update-check.service";
    };
  };

}
