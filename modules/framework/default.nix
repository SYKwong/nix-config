{ pkgs, ... }:

{
  imports = [
    ./framework-tool-tui.nix
    ./fw-fanctrl.nix
  ];

  environment.systemPackages = with pkgs; [
    
  ];
}

