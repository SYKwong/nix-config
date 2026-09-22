{ pkgs, ... }:

{
  home.packages = with pkgs; [
    amberol
    feishin
    jellyfin-desktop
  ];

  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      mpris
      thumbfast
      thumbfast-vanilla-osc
    ];
    config = {
      # Disable built-in OSC so thumbfast-vanilla-osc provides the controller
      osc = false;

      # Do not show OSD pop-up/bar when scrubbing/seeking
      osd-on-seek = "no";

      autocreate-playlist = "filter";
      directory-filter-types = "video";
      directory-mode = "ignore";
      save-position-on-quit = true;
    };
    bindings = {
      UP = "no-osd add volume 5";
      DOWN = "no-osd add volume -5";
      LEFT = "no-osd seek -5";
      RIGHT = "no-osd seek 5";
    };
  };
}
