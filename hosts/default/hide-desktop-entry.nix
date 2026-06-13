{ lib, ... }:

let
  # Apps that xdg.desktopEntries cannot hide
  annoyingApps = [
    "rofi"
    "rofi-theme-selector"
  ];

  appsToHide = [
    # Foot is only used for TUI app
    "foot"
    "foot-server"
    "footclient"

    # Installed as Stylix dependency
    "qt5ct"
    "qt6ct"
    "kvantummanager"

    # fcitx5
    "fcitx5-configtool"
    "org.fcitx.fcitx5-migrator"
    "org.fcitx.Fcitx5"
    "kbd-layout-viewer5"

    # KDE stuff
    "org.kde.konsole"

    # Misc
    "nixos-manual"
    "btop"
    "uuctl"
    "qimgv"
    "mpv"
  ];

  hiddenDesktopContent = name: ''
    [Desktop Entry]
    Type=Application
    Name=${name}
    Exec=true
    NoDisplay=true
    Hidden=true
  '';
in
{
  xdg.desktopEntries = lib.genAttrs appsToHide (name: {
    inherit name;
    noDisplay = true;
    exec = name;
  });

  home.file = lib.listToAttrs (
    map (name: {
      name = ".local/share/applications/${name}.desktop";
      value = {
        text = hiddenDesktopContent name;
        force = true;
      };
    }) annoyingApps
  );
}
