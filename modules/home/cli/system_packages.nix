{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fzf
    neovim
    wget
    wiremix
    zoxide
  ];

  programs = {
    bat.enable = true;
  };
}
