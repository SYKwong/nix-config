{ hostname, ... }:

{
  imports = [ 
    ./../../modules/home/cli 
  ];
  
  # UWSM quirk with systemd 
  wayland.windowManager.hyprland.systemd.enable = false;
  
  xdg.configFile."hypr/hyprland.conf".source = ./../../config/hypr/hyprland/hosts/${hostname}.conf;
  xdg.configFile."hypr/hyprland/common".source = ./../../config/hypr/hyprland/common;

  xdg.configFile."hypr/hypridle.conf".source = ./../../config/hypr/hypridle/hosts/${hostname}.conf;
  xdg.configFile."hypr/hypridle/common".source = ./../../config/hypr/hypridle/common;

  xdg.configFile."hypr/hyprlock.conf".source = ./../../config/hypr/hyprlock/hyprlock.conf;

  xdg.configFile."hypr/hyprpaper.conf".source = ./../../config/hypr/hyprpaper/hyprpaper.conf;
  xdg.configFile."hypr/wallpaer".source = ./../../config/hypr/hyprpaper/wallpaper;

  xdg.configFile."waybar".source = ./../../config/waybar;

  xdg.configFile."rofi".source = ./../../config/rofi;


  programs.bash = {
    enable = true;
    profileExtra = ''
      if uwsm check may-start; then
        exec uwsm start hyprland.desktop
      fi
    '';
  };
  
  home.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake ~/nix-config/#${hostname}";
    nrb = "sudo nixos-rebuild boot --flake ~/nix-config/#${hostname}";
  };
}
