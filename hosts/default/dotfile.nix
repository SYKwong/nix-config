{ config, hostname, username, ... }:
let
  config_path = "/home/${username}/nix-config/config";
  symlink     = path: config.lib.file.mkOutOfStoreSymlink "${config_path}/${path}";

  files = {
    "hypr/hyprland.lua"         = "hypr/hyprland/hyprland.lua";
    "hypr/hyprland/common"      = "hypr/hyprland/common";
    "hypr/hypridle_hosts.conf"  = "hypr/hypridle/hosts/${hostname}.conf";
    "hypr/hypridle.conf"        = "hypr/hypridle/hypridle.conf";
    "hypr/hyprlock.conf"        = "hypr/hyprlock/hyprlock.conf";
    "hypr/hyprpaper.conf"       = "hypr/hyprpaper/hyprpaper.conf";
    "hypr/mocha.conf"           = "hypr/mocha.conf";
    "hypr/cat_on_line.png"      = "hypr/hyprlock/cat_on_line.png";

    "waybar"  = "waybar";
    "rofi"    = "rofi";
    "swayosd" = "swayosd";
    "foot"    = "foot";
    "kitty"   = "kitty";
    "swaync"  = "swaync";

    "dolphinrc" = "kde/dolphin/dolphinrc";
  };
in 
{
  xdg.configFile = builtins.mapAttrs (name: value: { source = symlink value; }) files;
}
