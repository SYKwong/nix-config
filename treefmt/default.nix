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
}
