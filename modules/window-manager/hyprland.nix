{ lib, ... }:

{
  programs.hyprland = {
    enable = lib.mkDefault true;
    withUWSM = true;
  };
}
