_:

{
  hardware.fw-fanctrl.enable = true;

  environment.systemPackages = [
    # Temporarily disabled due to upstream nixpkgs libgit2 build failure (#61)
    # pkgs.framework-tool-tui
  ];
}
