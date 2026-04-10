{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
    neovim
    wget
    wiremix
    jq
  ];

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "kitty.desktop" ];
  };

}
