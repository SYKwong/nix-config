{ lib, ... }:

let
  tuiApps = [
    { name = "impala";  
      desktopName = "Wi-Fi"; 
      icon = "network-wireless"; }
    { name = "bluetui"; 
      desktopName = "Bluetooth"; 
      icon = "bluetooth"; }
    { name = "wiremix";  
      desktopName = "Audio"; 
      icon = "multimedia-volume-control"; }
  ];
in
{
  xdg.desktopEntries = lib.listToAttrs (map (app: {
    name = app.name;
    value = {
      name = app.desktopName or app.name;
      exec = app.name;
      terminal = true;
      icon = app.icon;
  };}) tuiApps);
}
