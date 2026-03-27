{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    wget
    wiremix
  ];

}
