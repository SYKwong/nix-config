{ config, pkgs, lib, ... }:

{
   environment.systemPackages = with pkgs; [
    bat
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
}
