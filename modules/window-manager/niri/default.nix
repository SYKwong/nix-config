{ pkgs, ... }:

{
  imports = [
    ../hypridle.nix
    ../hyprlock.nix
    ../kb-light-manager.nix
    ../notifications.nix
    ../swayosd.nix
    ../waybar.nix
  ];

  programs = {
    niri.enable = true;
    xwayland-satellite.enable = true;
    dms-shell.enable = true;
  };

  environment.systemPackages = with pkgs; [ alacritty ];
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    configPackages = [ pkgs.niri ];
  };

  services.gnome.gnome-keyring.enable = true;
}
