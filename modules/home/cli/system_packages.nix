{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fzf
    neovim
    tre-command
    wget
    wiremix
    zoxide
  ];

  programs = {
    bat.enable = true;
  };
}
