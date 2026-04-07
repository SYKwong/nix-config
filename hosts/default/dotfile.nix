{ hostname, ... }:

{
  # UWSM quirk with systemd 
  wayland.windowManager.hyprland.systemd.enable = false;
  
  xdg.configFile."hypr/hyprland.conf".source = ./../../config/hypr/hyprland/hosts/${hostname}.conf;
  xdg.configFile."hypr/hyprland/common".source = ./../../config/hypr/hyprland/common;

  xdg.configFile."hypr/hypridle.conf".source = ./../../config/hypr/hypridle/hosts/${hostname}.conf;
  xdg.configFile."hypr/hypridle/common".source = ./../../config/hypr/hypridle/common;

  xdg.configFile."hypr/hyprlock.conf".source = ./../../config/hypr/hyprlock/hyprlock.conf;

  xdg.configFile."hypr/hyprpaper.conf".source = ./../../config/hypr/hyprpaper/hyprpaper.conf;
  xdg.configFile."hypr/wallpaper".source = ./../../config/hypr/hyprpaper/wallpaper;

  xdg.configFile."niri/config.kdl".source = ./../../config/niri/config.kdl;

  xdg.configFile."waybar".source = ./../../config/waybar;

  xdg.configFile."rofi".source = ./../../config/rofi;
}
