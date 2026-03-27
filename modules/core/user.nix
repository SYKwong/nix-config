{ config, lib, pkgs, username, ... }:

{
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}

