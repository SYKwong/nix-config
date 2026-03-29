{ hostname, ... }:

{
  imports = [ 
    ./../../modules/home/cli 
  ];

  wayland.windowManager.hyprland.systemd.enable = false;
  
  home.file.".config/hypr/hyprland.conf".source = ./../../config/hypr/hosts/${hostname}.conf;
  home.file.".config/hypr/common".source = ./../../config/hypr/common;

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
