{ config, hostname, ... }:
let
  config_path = "$HOME/nix-config/config";
in 
{
  # UWSM quirk with systemd 
  wayland.windowManager.hyprland.systemd.enable = false;
  
  xdg.configFile."hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/hypr/hyprland/hosts/${hostname}.conf";

  xdg.configFile."hypr/hyprland/common".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/hypr/hyprland/common";

  xdg.configFile."hypr/hypridle.conf".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/hypr/hypridle/hosts/${hostname}.conf";
  xdg.configFile."hypr/hypridle/common".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/hypr/hypridle/common";

  xdg.configFile."hypr/hyprlock.conf".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/hypr/hyprlock/hyprlock.conf" ;

  xdg.configFile."hypr/hyprpaper.conf".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/hypr/hyprpaper/hyprpaper.conf";
  xdg.configFile."hypr/wallpaper".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/hypr/hyprpaper/wallpaper";

  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/niri/hosts/${hostname}.kdl";
  xdg.configFile."niri/animation.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/niri/common/animation.kdl";
  xdg.configFile."niri/auto-start.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/niri/common/auto-start.kdl";
  xdg.configFile."niri/input.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/niri/common/input.kdl";
  xdg.configFile."niri/keybind.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/niri/common/keybind.kdl";
  xdg.configFile."niri/layout.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/niri/common/layout.kdl";
  xdg.configFile."niri/misc.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/niri/common/misc.kdl";
  xdg.configFile."niri/window-rule.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/niri/common/window-rule.kdl";

  xdg.configFile."waybar".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/waybar";

  xdg.configFile."rofi".source = config.lib.file.mkOutOfStoreSymlink "${config_path}/rofi";
}
