{ pkgs, lib, username, ... }: 

{
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "start-hyprland &>/dev/null";
        user = "${username}";
      };
      default_session = {
        command = "start-hyprland &>/dev/null";
        user = "${username}";
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = lib.mkForce "simple";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Redirect errors so they don't print to screen
    TTYReset = "yes";
    TTYVHangup = "yes";
    TTYVTDisallocate = "yes";
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  services.udev.packages = [ pkgs.swayosd ];
  systemd.user.services.swayosd = {
    description = "SwayOSD Display Daemon";
  
    # Ensure it only starts after the graphical session is ready
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
      Restart = "always";
      RestartSec = "3";
    };
  };

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
    
    hyprlock.enable = true;
  };

  environment.systemPackages = with pkgs; [
    hypridle hyprpolkitagent
    waybar
    grim slurp
    kitty
    rofi
    satty
    swayosd playerctl brightnessctl
  ];
}
