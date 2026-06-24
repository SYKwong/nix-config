{
  programs.nixvim.plugins = {
    nvim-autopairs.enable = true;
    gitsigns.enable = true;
    neo-tree = {
      enable = true;
      settings = {
        enable_git_status = true;
        window.width = 30;
        close_if_last_window = true;
      };
    };
    telescope = {
      enable = true;
      keymaps = {
        "<leader><space>" = "find_files";
        "<leader>ff" = "find_files";
        "<leader>fg" = "live_grep";
        "<leader>fb" = "buffers";
        "<leader>fh" = "help_tags";
      };
    };

    treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    treesitter-context.enable = true;

    treesitter-textobjects = {
      enable = true;
      settings.select = {
        enable = true;
        lookahead = true;
      };
    };

    cmp = {
      enable = true;
      settings = {
        autoEnableSources = true;
        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        };
      };
    };

    conform-nvim = {
      enable = true;
      settings.format_on_save.timeout_ms = 500;
    };
    lint.enable = true;
    nix.enable = true;
    bufdelete.enable = true;
  };
}
