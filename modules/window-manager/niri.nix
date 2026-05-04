{ config, pkgs, lib, window-manager, ... }:

{
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
}

