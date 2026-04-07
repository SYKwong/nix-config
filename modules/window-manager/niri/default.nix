{ pkgs, ... }:

{
  imports = [
    ../dms.nix
    ../greetd.nix
    ../hypridle.nix
    ../hyprlock.nix
    ../kb-light-manager.nix
    ../notifications.nix
    ../swayosd.nix
    ];

  _module.args.session-command = "niri-session";

  programs = {
    niri.enable = true;
    dms-shell.enable = true;
  };

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

  services.gnome.gnome-keyring.enable = true;
}
