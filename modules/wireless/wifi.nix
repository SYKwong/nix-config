{ config, pkgs, lib, ... }:

let
  cfg = config.custom.wireless.wifi;  
in 
{
  config = lib.mkIf cfg.enable {
    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = "iwd";
    networking.networkmanager.wifi.powersave = true;
  
    environment.systemPackages = with pkgs; [ impala ];

  };
}
