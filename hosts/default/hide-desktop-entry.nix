 { lib, ... }:

let
  annoyingApps = [
    "rofi"
    "rofi-theme-selector"
    "waydroid.com.android.vending"
    "waydroid.com.google.android.apps.messaging"
    "waydroid.com.google.android.contacts"
    "waydroid.com.google.android.apps.restore"
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

    # Misc
    "nixos-manual"
    "btop"
    "uuctl"

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
  });

  home.file = lib.listToAttrs (map (name: {
    name = ".local/share/applications/${name}.desktop";
    value = { text = hiddenDesktopContent name; };
  }) annoyingApps);
}
