{ config, pkgs, lib, ... }:

{
   environment.systemPackages = with pkgs; [
    btop
    eza
    fastfetch
    fzf
    git
    lazygit
    neovim
    tree
    wget
    wiremix
    zoxide
  ];

  programs = {
    bat = enable;
  };
}
