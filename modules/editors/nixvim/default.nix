{ lib, ... }:

{
  programs.neovim.enable = lib.mkForce false;

  imports = [
    ./autocmd.nix
    ./options.nix
    ./keymaps.nix
    ./ui.nix
    ./plugins.nix
    ./lsp.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
  };
}
