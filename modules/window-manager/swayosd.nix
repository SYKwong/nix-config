{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    swayosd playerctl brightnessctl
  ];
  services.udev.packages = [ pkgs.swayosd ];
}
