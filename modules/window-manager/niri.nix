{ config, pkgs, lib, window-manager, ... }:

{
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    xwayland-satellite
  ];
  
  xdg.portal.configPackages = [ pkgs.niri ];
}

