{ pkgs, lib, username, ... }: 
  
{
  imports = [
    ../kb-light-manager.nix
    ../rofi.nix
    ../swayosd.nix
    ../waybar.nix
  ];

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
    grim slurp satty
  ];

}
