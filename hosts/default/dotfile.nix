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

  xdg.configFile."niri/config.kdl".source = ./../../config/niri/hosts/${hostname}.kdl;
  xdg.configFile."niri/animation.kdl".source = ./../../config/niri/common/animation.kdl;
  xdg.configFile."niri/auto-start.kdl".source = ./../../config/niri/common/auto-start.kdl;
  xdg.configFile."niri/input.kdl".source = ./../../config/niri/common/input.kdl;
  xdg.configFile."niri/keybind.kdl".source = ./../../config/niri/common/keybind.kdl;
  xdg.configFile."niri/layout.kdl".source = ./../../config/niri/common/layout.kdl;
  xdg.configFile."niri/misc.kdl".source = ./../../config/niri/common/misc.kdl;
  xdg.configFile."niri/window-rule.kdl".source = ./../../config/niri/common/window-rule.kdl;

  xdg.configFile."waybar".source = ./../../config/waybar;

  xdg.configFile."rofi".source = ./../../config/rofi;
}
