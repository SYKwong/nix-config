{ config, lib, pkgs, username, ... }:

{
  imports = [
    ./boot.nix
    ./networking.nix
    ./stylix.nix
    ./system.nix
    ./user.nix
  ];
}

