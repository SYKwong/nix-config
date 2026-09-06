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
  security.pam.services = {
    login.fprintAuth = false;
    ly.fprintAuth = false;
  };

  services.displayManager = {
    defaultSession = "hyprland-uwsm";
    ly = {
      enable = true;
      x11Support = false;
      settings = {
        bigclock = true;
        bigclock_12hr = true;

        hide_key_hints = true;
        hide_version_string = true;

        waylandsessions = "${waylandSessions}";
      };
    };
  };
}
