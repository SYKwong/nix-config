{ inputs, lib, ... }:

{
  programs.neovim.enable = lib.mkForce false;
  stylix.targets.nixvim.enable = false;
  imports = [
    inputs.nixvim.homeModules.nixvim

    ./language

    ./autocmd.nix
    ./options.nix
    ./keymaps.nix
    ./ui.nix
    ./plugins.nix
    ./term.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    # https://github.com/nix-community/nixvim/issues/4460
    # Remove the following line when the issue is resolved
    nixpkgs.useGlobalPackages = true;
  };
}
