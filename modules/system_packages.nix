{ config, pkgs, lib, ... }:

{
   environment.systemPackages = with pkgs; [
    eza
    fastfetch
    fzf
    lazygit
    neovim
    tree
    wget
    wiremix
    zoxide
  ];

  programs = {
    bat.enable = true;
    gh.enable = true;
    git.enable = true;
  };
}
