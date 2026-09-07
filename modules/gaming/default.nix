{ pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
      protontricks.enable = true;
    };

    gamescope = {
      enable = true;
      enableWsi = true;
    };

    gamemode.enable = true;
  };

  environment.systemPackages = [ pkgs.protonup-qt ];

  services.udev.packages = [ pkgs.game-devices-udev-rules ];
}
