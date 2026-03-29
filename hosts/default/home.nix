{ hostname, ... }:

{
  imports = [ 
    ./../../modules/home/cli 
  ];

  wayland.windowManager.hyprland.systemd.enable = false;
  
  xdg.configFile."hypr/hyprland.conf".source = ./../../config/hypr/hosts/${hostname}.conf;
  xdg.configFile."hypr/common".source = ./../../config/hypr/common;
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
}
