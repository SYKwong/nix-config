{ hostname, ... }:

{
  imports = [ 
    ./../../modules/home/cli 
  ];

  wayland.windowManager.hyprland.systemd.enable = false;
  
  xdg.configFile."hypr/hyprland.conf".source = ./../../config/hypr/hyprland/hosts/${hostname}.conf;
  xdg.configFile."hypr/hyprland/common".source = ./../../config/hypr/hyprland/common;

  xdg.configFile."hypr/hypridle.conf".source = ./../../config/hypr/hypridle/hosts/${hostname}.conf;
  xdg.configFile."hypr/hypridle/common".source = ./../../config/hypr/hypridle/common;

  xdg.configFile."waybar".source = ./../../config/waybar;

  home.file."debug_hostname.txt".text = "Hostname is: ${hostname}";

  programs.bash = {
    enable = true;
    profileExtra = ''
      if uwsm check may-start; then
        exec uwsm start hyprland.desktop
      fi
    '';
  };
  
  home.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake .#${hostname}";
    nrb = "sudo nixos-rebuild boot --flake .#${hostname}";
  };
}
