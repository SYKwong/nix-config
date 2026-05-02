{ config, pkgs, lib, window-manager, ... }:

{
  #config = lib.mkIf (window-manager == "niri"){

  #  _module.args.session-command = "niri-session";

    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [
      alacritty
      xwayland-satellite
    ];
    
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      configPackages = [ pkgs.niri ];
    };
  
  #};
}

