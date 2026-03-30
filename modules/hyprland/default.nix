{ pkgs, username, ... }: 

{
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "start-hyprland";
        user = "${username}";
      };
      default_session = {
        command = "start-hyprland";
        user = "${username}";
      };
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
    hypridle
    hyprpolkitagent
    waybar
    grim
    slurp
    kitty
    rofi
    satty
  ];
}
