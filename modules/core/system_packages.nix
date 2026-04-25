{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
    neovim
    wget
    wiremix
    wl-clipboard
    psmisc
  ];

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "kitty.desktop" ];
  };

}
