{ config, lib, pkgs, ... }:

{
  system.stateVersion = "25.11";

  time.timeZone = "America/Los_Angeles";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
  };
}

