{ config, lib, pkgs, username, ... }:

{
  imports = [
    ./boot.nix
    ./fonts.nix
    ./hardware.nix
    ./networking.nix
    ./stylix.nix
    ./system.nix
    ./user.nix
  ];
}

