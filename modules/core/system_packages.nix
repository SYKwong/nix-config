{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
    neovim
    wget
    wiremix
  ];

}
