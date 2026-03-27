{ config, lib, pkgs, username, ... }:

{
  imports = [
    ./boot.nix
    ./networking.nix
    ./system.nix
    ./user.nix
  ]
}

