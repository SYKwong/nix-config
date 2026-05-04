{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    hyprpolkitagent
  ];

  systemd.user.services.hyprpolkitagent = {
    description = "Hyprpolkit authentication agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}

