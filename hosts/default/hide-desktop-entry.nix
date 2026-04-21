{ lib, ... }:

let
  appsToHide = [   
  ];
in
{
  xdg.desktopEntries = lib.genAttrs appsToHide (name: {
    inherit name;
    noDisplay = true;
  });
}
