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

  rebuild = import ./rebuild.nix common;

  scripts = {
    inherit rebuild;
    post-install = import ./post-install.nix common;
    kb-light-manager = import ./kb-light-manager.nix common;
    rofi-keybind = import ./rofi-keybind.nix common;
    display-brightness = import ./display-brightness.nix common;
    hypr-virtual-monitor = import ./hypr-virtual-monitor.nix common;
    safe-python = import ./safe-python.nix common;
    update-wallpaper = import ./update-wallpaper.nix (common // { inherit rebuild; });
  };
in
{
  imports = [
    ./tui-wrap.nix
  ];

  environment.systemPackages = builtins.attrValues scripts;
}
