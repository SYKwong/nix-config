{ pkgs, config, ... }:

{
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = null;
    templates = null;
    publicShare = null;
    extraConfig = {
      SCREENSHOTS = "${config.xdg.userDirs.pictures}/Screenshots";
    };
  };

  home.packages = [ pkgs.papirus-icon-theme ];
}
