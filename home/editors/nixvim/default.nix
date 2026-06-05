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
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
  };
}
