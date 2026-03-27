{ config, pkgs, ... }:

{
  imports = [ 
    ./../../modules/home/cli 
  ];

  wayland.windowManager.hyprland.systemd.enable = false;

  programs.bash = {
    enable = true;
    profileExtra = ''
      if uwsm check may-start; then
        exec uwsm start hyprland.desktop
      fi
    '';
  };
}
