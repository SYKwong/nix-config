{ pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    extraPortals =  with pkgs; [ 
      xdg-desktop-portal-gnome 
      xdg-desktop-portal-gtk
    ];
  
    config.common.default = [ "gtk" ];
    config.gnome.default = [ "gnome" "gtk" ];
  };
}
