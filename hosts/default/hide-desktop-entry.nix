{ lib, ... }:

let
  appsToHide = [
    # Hide all waydroid pre-installed apps 
    
  ];
in
{
  xdg.desktopEntries = lib.genAttrs appsToHide (name: {
    inherit name;
    noDisplay = true;
  });
}
