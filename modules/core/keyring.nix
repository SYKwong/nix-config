{ lib, config, ... }:
{
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.hyprlock.enableGnomeKeyring = lib.mkIf config.programs.hyprlock.enable true;
}
