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
  xdg.desktopEntries = lib.genAttrs appsToHide (name: {
    inherit name;
    noDisplay = true;
  });
}
