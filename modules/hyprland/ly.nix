{
  config,
  pkgs,
  ...
}:

let
  waylandSessions = pkgs.runCommand "ly-wayland-sessions" { } ''
    mkdir -p "$out"
    shopt -s nullglob
    for f in ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions/*.desktop; do
      if [ "$(basename "$f")" != "hyprland.desktop" ]; then
        ln -s "$f" "$out/"
      fi
    done
  '';
in
{
  security.pam.services.ly = {
    fprintAuth = false;
    enableGnomeKeyring = config.services.gnome.gnome-keyring.enable;
  };

  services.displayManager.ly = {
    enable = true;
    x11Support = false;
    settings = {
      bigclock = "en";
      bigclock_12hr = true;

      corner_bottom_left = "null";
      corner_top_left = "null";

      waylandsessions = "${waylandSessions}";
    };
  };
}
