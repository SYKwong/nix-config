{
  pkgs,
  hostname,
  username,
  ...
}:

let
  config_path = "/home/${username}/nix-config";

  common = {
    inherit
      pkgs
      hostname
      username
      config_path
      ;
  };

  scripts = {
    fcitx5-tray = import ./fcitx5-tray.nix common;

    update-available = import ./update-available.nix common;
    update-system = import ./update-system.nix common;

    rofi-menu = import ./rofi-menu.nix common;
    rofi-power-menu = import ./rofi-power-menu.nix common;
    rofi-profile-menu = import ./rofi-profile-menu.nix common;
    rofi-wallpaper-picker = import ./rofi-wallpaper-picker.nix common;
  };
in
{
  imports = [
    ./tui-wrap.nix
    ./reload-waybar.nix
  ];

  environment.systemPackages = builtins.attrValues scripts;
}
