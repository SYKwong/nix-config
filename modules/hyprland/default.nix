{
  config,
  pkgs,
  inputs,
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
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  environment.systemPackages = [
    (pkgs.callPackage ./scrolloverview.nix {
      src = inputs.hyprland-scroll-overview;
    })
  ];

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
        bigclock = "en";
        bigclock_12hr = true;

        corner_bottom_left = "null";
        corner_top_left = "null";

        waylandsessions = "${waylandSessions}";
      };
    };
  };
}
