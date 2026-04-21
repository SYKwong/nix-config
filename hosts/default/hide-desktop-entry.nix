{ lib, ... }:

let
  appsToHide = [
    # Foot is only used for TUI app
    "foot"
    "foot-server"
    "footclient"

    # Installed as Stylix dependency
    "qt5ct"
    "qt6ct"

    # Misc
    "nixos-manual"
    "rofi-theme-selector" 
  ];
in
{
  xdg.dataFile = lib.listToAttrs (map (name: {
    name = "applications/${name}.desktop";
    value = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=${name}
        Exec=true
        NoDisplay=true
      '';
    };
  }) appsToHide);
}
