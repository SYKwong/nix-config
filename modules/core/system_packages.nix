{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
    neovim
    wget
    wiremix
    wl-clipboard
  ];

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "kitty.desktop" ];
  };

}
