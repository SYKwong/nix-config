{ config, pkgs, lib, ... }:

{
   environment.systemPackages = with pkgs; [
    wiremix
    neovim
    wget
    tree
    git
    bat
    eza
    fzf
    btop
    zoxide
    lazygit
  ];
}
