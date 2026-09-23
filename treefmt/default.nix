{
  projectRootFile = "flake.nix";

  programs = {
    # nix
    nixfmt.enable = true;

    #lua
    stylua.enable = true;

    #bash
    shellcheck.enable = true;
    shfmt.enable = true;
  };

  settings.formatter.shfmt.options = [
    "-i"
    "2"
    "-ci"
    "-s"
  ];
}
