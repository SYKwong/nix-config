{ inputs, ... }:

{
  stylix.targets.nixvim.enable = false;
  imports = [
    inputs.nixvim.homeModules.nixvim

    ./language

    ./autocmd.nix
    ./options.nix
    ./keymaps.nix
    ./ui.nix
    ./plugins.nix
    ./plugins-minuet.nix
    ./term.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
