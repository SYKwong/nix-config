{
  programs.nixvim.plugins = {
    bufdelete.enable = true;

    cmp = {
      enable = true;
      settings = {
        autoEnableSources = true;
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        };
        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };
    };

    conform-nvim = {
      enable = true;
      settings.format_on_save.timeout_ms = 500;
    };

    lint.enable = true;

    lsp = {
      enable = true;
      keymaps.lspBuf = {
        "<leader>ca" = "code_action";
        "<leader>rn" = "rename";
        "K" = "hover";
        "gd" = "definition";
        "gr" = "references";
      };
    };

    nvim-autopairs.enable = true;

    treesitter-textobjects = {
      enable = true;
      settings.select = {
        enable = true;
        lookahead = true;
      };
    };
  };
}
