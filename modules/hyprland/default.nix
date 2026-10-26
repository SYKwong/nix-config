{
  pkgs,
  inputs,
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
    (pkgs.callPackage ./scrolloverview.nix {
      src = inputs.hyprland-scroll-overview;
    })
  ];

  security.pam.services = {
    login.fprintAuth = false;
  };

  services.displayManager = {
    defaultSession = "hyprland-uwsm";
  };
}
