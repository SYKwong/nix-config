{ config, pkgs, ... }:

{
  imports = [ 
    ./../../modules/home/cli 
  ];

  wayland.windowManager.hyprland.systemd.enable = false;
  
  home.file.".config/hypr".source = ./../../config/hypr;
  home.file.".config/waybar".source = ./../../config/waybar;


  programs.bash = {
    enable = true;
    profileExtra = ''
      if uwsm check may-start; then
        exec uwsm start hyprland.desktop
      fi
    '';
  };
}
