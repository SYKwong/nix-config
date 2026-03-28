{ config, pkgs, ... }:

{
  imports = [ 
    ./../../modules/home/cli 
  ];

  programs.bash = {
    enable = true;
    profileExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec hyprland
      fi
    '';
  };
}
