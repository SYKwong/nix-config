{ config, lib, pkgs, username, ... }:

{
  imports = [
    ./boot.nix
    ./fonts.nix
    ./fwupd.nix
    ./hardware.nix
    ./networking.nix
    ./stylix.nix
    ./system.nix
    ./user.nix
  ];
}

