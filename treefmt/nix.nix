{
  programs = {
    deadnix.enable = true;
    nixfmt.enable = true;
    statix.enable = true;
  };

  settings.global.excludes = [
    "*/hardware-configuration.nix"
  ];
}
