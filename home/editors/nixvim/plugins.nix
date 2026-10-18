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

    gitsigns.enable = true;

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

    neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        enable_git_status = true;
        filesystem = {
          filtered_items = {
            hide_dotfiles = false;
            hide_gitignored = false;
            never_show = [
              ".astro"
              ".git"
              "dist"
              "node_modules"
            ];
            visible = true;
          };
        };
        window.width = 30;
      };
    };

    nix.enable = true;

    nvim-autopairs.enable = true;

    telescope = {
      enable = true;
      keymaps = {
        "<leader><space>" = "find_files";
        "<leader>fb" = "buffers";
        "<leader>ff" = "find_files";
        "<leader>fg" = "live_grep";
        "<leader>fh" = "help_tags";
      };
      settings = {
        defaults = {
          layout_config = {
            horizontal = {
              preview_cutoff = 0;
            };
            preview_cutoff = 0;
          };
          file_ignore_patterns = [
            "^%.astro/"
            "[/\\]%.astro/"
            "^%.git/"
            "[/\\]%.git/"
            "^%.git$"
            "[/\\]%.git$"
            "^dist/"
            "[/\\]dist/"
            "^node_modules/"
            "[/\\]node_modules/"
          ];
        };
        pickers = {
          find_files = {
            hidden = true;
          };
          live_grep = {
            additional_args = [
              "--hidden"
              "--glob=!**/.astro/*"
              "--glob=!**/.git/*"
              "--glob=!**/dist/*"
              "--glob=!**/node_modules/*"
            ];
          };
        };
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
  };
}
