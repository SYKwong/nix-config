{ pkgs, ... }:

{
  hardware.fw-fanctrl.enable = true;

  environment.systemPackages = [
    pkgs.framework-tool-tui
  ];
}
