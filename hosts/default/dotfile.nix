{ config, hostname, username, ... }:
let
  config_path = "/home/${username}/nix-config/config";
  symlink = path: config.lib.file.mkOutOfStoreSymlink "${config_path}/${path}";

  files = {
    "hypr/hyprland.conf"    = "hypr/hyprland/hosts/${hostname}.conf";
    "hypr/hyprland/common"  = "hypr/hyprland/common";
    "hypr/hypridle.conf"    = "hypr/hypridle/hosts/${hostname}.conf";
    "hypr/hypridle/common"  = "hypr/hypridle/common";
    "hypr/hyprlock.conf"    = "hypr/hyprlock/hyprlock.conf";
    "hypr/hyprpaper.conf"   = "hypr/hyprpaper/hyprpaper.conf";
    "hypr/wallpaper"        = "hypr/hyprpaper/wallpaper";
    "hypr/mocha.conf"       = "hypr/mocha.conf";
    "hypr/cat_on_line.png"  = "hypr/hyprlock/cat_on_line.png";

    "niri/config.kdl"       = "niri/hosts/${hostname}.kdl";
    "niri/animation.kdl"    = "niri/common/animation.kdl";
    "niri/auto-start.kdl"   = "niri/common/auto-start.kdl";
    "niri/input.kdl"        = "niri/common/input.kdl";
    "niri/keybind.kdl"      = "niri/common/keybind.kdl";
    "niri/layout.kdl"       = "niri/common/layout.kdl";
    "niri/misc.kdl"         = "niri/common/misc.kdl";
    "niri/window-rule.kdl"  = "niri/common/window-rule.kdl";

    "waybar"  = "waybar";
    "rofi"    = "rofi";
    "swayosd" = "swayosd";
    "mako"    = "mako";
    "foot"    = "foot";
    "kitty"   = "kitty";
    "starship"= "starship";	
  };
in 
{
  xdg.configFile = builtins.mapAttrs (name: value: { source = symlink value; }) files;
}
