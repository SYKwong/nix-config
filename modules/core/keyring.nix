{ pkgs, lib, config, ... }:
{
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.hyprlock.enableGnomeKeyring = lib.mkIf config.programs.hyprlock.enable true;
  systemd.user.services.gnome-keyring = {
    description = "GNOME Keyring";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.freedesktop.secrets";
      ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --foreground --components=secrets";
      #ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --foreground --components=secrets";
    Restart = "on-abort";
    };
    wantedBy = [ "graphical-session.target" ];
  };
}
