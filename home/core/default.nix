{ pkgs, ... }:

{
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = null;
    templates = null;
    publicShare = null;
  };

  home.packages = [ pkgs.papirus-icon-theme ];
}
