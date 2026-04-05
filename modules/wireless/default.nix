/**
 * Wireless Module
 * * This module manages WiFi (via iwd/NetworkManager) and Bluetooth.
 * Both features are ENABLED by default.
 *
 * To disable a feature in your host configuration:
 * custom.wireless.wifi.enable = false;
 * custom.wireless.bluetooth.enable = false;
 */
{ lib, ...}:

{
  imports = [
    ./bluetooth.nix
    ./wifi.nix
  ];

  options.custom.wireless = {
    wifi.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable WiFi support. Default is true.";
    };

    bluetooth.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Bluetooth support. Default is true.";
    };
  };
}
