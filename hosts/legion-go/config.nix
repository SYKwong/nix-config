{
  # Early boot console rotation for native portrait panel (1600x2560)
  boot.kernelParams = [
    "video=eDP-1:panel_orientation=right_side_up"
    "fbcon=rotate:1"
  ];

  # Gamescope display parameters specific to Lenovo Legion Go 8.8" 144Hz panel
  programs.steam.gamescopeSession.args = [
    "--prefer-output"
    "eDP-1"
    "-w"
    "2560"
    "-h"
    "1600"
    "-W"
    "2560"
    "-H"
    "1600"
    "-r"
    "144"
    "--force-orientation"
    "left"
    "--force-composition-rotation"
  ];

  # Handheld console is a client device; disable Sunshine desktop streaming server
  custom.sunshine.enable = false;
}
