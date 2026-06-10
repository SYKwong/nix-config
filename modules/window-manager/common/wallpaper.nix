{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.swaybg
    pkgs.awww
  ];
}
