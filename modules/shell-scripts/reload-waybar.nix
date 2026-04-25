{ pkgs, ... }:

let
  reload-waybar = pkgs.writeShellScriptBin "reload-waybar" ''
    killall -SIGUSR2 waybar
    ''
  ;
in
{
  environment.systemPackages = [ 
    reload-waybar
  ];
}
