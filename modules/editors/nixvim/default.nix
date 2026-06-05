{ lib, ... }:

{
  programs.neovim.enable = lib.mkForce false;

  imports = [
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
