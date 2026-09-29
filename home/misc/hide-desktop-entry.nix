{ lib, ... }:

let
  # Apps that xdg.desktopEntries cannot hide
  annoyingApps = [
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
    "org.kde.ark"

    # Misc
    "btop"
    "dev.noctalia.Noctalia"
    "kitty"
    "mpv"
    "nvim"
    "qimgv"
    "uuctl"
    "yazi"
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
  xdg.desktopEntries = lib.genAttrs appsToHide (
    name:
    {
      inherit name;
      settings = {
        OnlyShowIn = "X-None;";
      };
      exec = name;
    }
    // lib.optionalAttrs (name == "nvim") {
      exec = "nvim %F";
      terminal = true;
      mimeType = [ "text/plain" ];
    }
    // lib.optionalAttrs (name == "qimgv") {
      exec = "qimgv %F";
      mimeType = [ "image/*" ];
    }
    // lib.optionalAttrs (name == "mpv") {
      exec = "mpv -- %U";
      mimeType = [ "video/*" ];
    }
    // lib.optionalAttrs (name == "org.kde.ark") {
      exec = "ark %U";
      mimeType = [
        "application/zip"
        "application/x-7z-compressed"
        "application/x-rar"
      ];
    }
  );

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
