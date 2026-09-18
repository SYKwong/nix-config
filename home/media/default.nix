{ pkgs, ... }:

{
  home.packages = with pkgs; [
    amberol
    jellyfin-desktop
    supersonic
  ];

  programs.mpv = {
    enable = true;
    config = {
      autocreate-playlist = "filter";
      directory-filter-types = "video";
      save-position-on-quit = true;
    };
    bindings = {
      UP = "add volume 5";
      DOWN = "add volume -5";
    };
  };
}
