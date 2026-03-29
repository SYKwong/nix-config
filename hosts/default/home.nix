{ hostname, ... }:

{
  imports = [ 
    ./../../modules/home/cli 
  ];

  wayland.windowManager.hyprland.systemd.enable = false;
  
  home.file.".config/hypr/hyprland.conf".source = ./../../config/hypr/hosts/${hostname}.conf;
  home.file.".config/hypr/common".source = ./../../config/hypr/common;

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
