{ pkgs, ... }:

{
  imports = [
    ../../shared/base_home.nix
  ];
  networking.wireless.enable = true;
}
