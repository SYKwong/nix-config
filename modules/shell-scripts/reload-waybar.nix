{ pkgs, ... }:

let
  reload-waybar = pkgs.writeShellScriptBin "reload-waybar" ''
    pkill -USR2 waybar
  '';
in
{
  environment.systemPackages = [ 
    reload-waybar
  ];
}
