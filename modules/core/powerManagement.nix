{ pkgs, lib, config, ... }:

{
  powerManagement.powerUpCommands = lib.mkIf config.programs.waybar.enable ''
    ${pkgs.coreutils}/bin/sleep 5 && ${pkgs.procps}/bin/pkill -RTMIN+7 waybar &
  '';
}
