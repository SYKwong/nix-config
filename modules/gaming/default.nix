{ pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      protontricks.enable = true;
    };

    gamescope = {
      enable = true;
      enableWsi = true;
    };
  };

  environment.systemPackages = [ pkgs.protonup-qt ];
}
