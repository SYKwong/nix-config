{ config, hostname, username, ... }:
let
  config_path = "/home/${username}/nix-config/config";
  symlink = path: config.lib.file.mkOutOfStoreSymlink "${config_path}/${path}";
in 
{
  # UWSM quirk with systemd 
  wayland.windowManager.hyprland.systemd.enable = false;
  
  xdg.configFile."hypr/hyprland.conf".source = symlink "hypr/hyprland/hosts/${hostname}.conf"; 
  xdg.configFile."hypr/hyprland/common".source = symlink "hypr/hyprland/common";

  xdg.configFile."hypr/hypridle.conf".source = symlink "hypr/hypridle/hosts/${hostname}.conf";
  xdg.configFile."hypr/hypridle/common".source = symlink "hypr/hypridle/common";

  xdg.configFile."hypr/hyprlock.conf".source = symlink "hypr/hyprlock/hyprlock.conf" ;

  xdg.configFile."hypr/hyprpaper.conf".source = symlink "hypr/hyprpaper/hyprpaper.conf";
  xdg.configFile."hypr/wallpaper".source = symlink "hypr/hyprpaper/wallpaper";

  xdg.configFile."niri/config.kdl".source = symlink "niri/hosts/${hostname}.kdl";
  xdg.configFile."niri/animation.kdl".source = symlink "niri/common/animation.kdl";
  xdg.configFile."niri/auto-start.kdl".source = symlink "niri/common/auto-start.kdl";
  xdg.configFile."niri/input.kdl".source = symlink "niri/common/input.kdl";
  xdg.configFile."niri/keybind.kdl".source = symlink "niri/common/keybind.kdl";
  xdg.configFile."niri/layout.kdl".source = symlink "niri/common/layout.kdl";
  xdg.configFile."niri/misc.kdl".source = symlink "niri/common/misc.kdl";
  xdg.configFile."niri/window-rule.kdl".source = symlink "niri/common/window-rule.kdl";

  xdg.configFile."waybar".source = symlink "waybar";

  xdg.configFile."rofi".source = symlink "rofi";

  xdg.configFile."swayosd".source = symlink "swayosd";
}
