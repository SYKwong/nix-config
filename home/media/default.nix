{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jellyfin-desktop
    supersonic
  ];

  programs.mpv = {
    enable = true;
    config = {
      autocreate-playlist = "filter";
    };
    bindings = {
      UP = "add volume 5";
      DOWN = "add volume -5";
    };
  };
}
