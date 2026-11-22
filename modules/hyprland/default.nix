{
  # inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./ly.nix
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  environment.systemPackages = [
    pkgs.hyprsunset
    # Temporarily disabled: crashes Hyprland v0.57.2 (SIGSEGV in renderDecorationTexture)
    # (pkgs.callPackage ./scrolloverview.nix {
    #   src = inputs.hyprland-scroll-overview;
    # })
  ];

  security.pam.services = {
    login.fprintAuth = false;
  };

  services.displayManager = {
    defaultSession = "hyprland-uwsm";
  };
}
