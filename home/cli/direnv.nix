{ config, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableFishIntegration = true;
    config.whitelist.prefix = [
      "${config.home.homeDirectory}/Projects/playground"
      "${config.home.homeDirectory}/Templates"
    ];
  };
}
