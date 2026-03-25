{ pkgs, ... }:

{
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.networkmanager.wifi.powersave = true;
  
  environment.systemPackages = with pkgs; [
    impala
  ];
}
