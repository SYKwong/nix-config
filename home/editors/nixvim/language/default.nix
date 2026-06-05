{
  imports = [
    ./lua.nix
    ./nix.nix
  ];

  programs.nixvim.plugins = {

    lsp = {
      enable = true;
      servers = {
        pyright.enable = true; # Python
      };
      keymaps.lspBuf = {
        "gd" = "definition";
        "gr" = "references";
        "K" = "hover";
        "<leader>ca" = "code_action";
        "<leader>rn" = "rename";
      };
    };
  };
}
