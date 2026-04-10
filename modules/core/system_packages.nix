{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
    neovim
    wget
    wiremix
    foot # for tui-warpper
  ];

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "kitty.desktop" ];
  };

}
