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
    ./system_packages.nix
    ./user.nix
  ];
}

