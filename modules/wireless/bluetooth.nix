{ config, pkgs, lib, ... }:

let
  cfg = config.custom.wireless.bluetooth;
in 
{
  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
    environment.systemPackages = with pkgs; [ bluetui ];
  };
}
