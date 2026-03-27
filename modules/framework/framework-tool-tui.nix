{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.framework-tool-tui
  ];
}
