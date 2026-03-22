{ pkgs, ... }:

{
  imports = [
    ../../base/base_home.nix
  ];
  networking.wireless.enable = true;
}
