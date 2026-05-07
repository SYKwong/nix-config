{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    swaynotificationcenter
    libnotify
  ];
}
