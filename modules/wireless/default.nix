/**
  Wireless Module
  * This module manages WiFi (via iwd/NetworkManager) and Bluetooth.
  Both features are ENABLED by default.

  To disable a feature in your host configuration:
  custom.wireless.wifi.enable = false;
  custom.wireless.bluetooth.enable = false;
*/
{ lib, ... }:

{
  imports = [
    ./bluetooth.nix
    ./wifi.nix
  ];

  options.custom.wireless = {
    wifi.enable = lib.mkEnableOption "WiFI Support" // {
      default = true;
    };

    bluetooth.enable = lib.mkEnableOption "Bluetooth Support" // {
      default = true;
    };
  };
}
