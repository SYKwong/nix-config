{ pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
      protontricks.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    gamescope = {
      enable = true;
      enableWsi = true;
    };

    gamemode = {
      enable = true;
      settings = {
        custom = {
          start = "${pkgs.systemd}/bin/systemctl --user stop nixos-cache-warm.service 2>/dev/null || true";
        };
      };
    };
  };

  environment.systemPackages = [ pkgs.protonup-qt ];

  services.udev.packages = [ pkgs.game-devices-udev-rules ];
}
