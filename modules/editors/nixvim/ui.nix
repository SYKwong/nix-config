{
  programs.nixvim = {
    opts.termguicolors = true;
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = true;
        custom_highlights = ''
          function(colors)
            return {
              CursorLine = { bg = "none", undercurl = true, sp = colors.mauve },
              CursorLineNr = { fg = colors.mauve, bold = true },
            }
          end
        '';
        integrations = {
          alpha = true;
          bufferline = true;
          gitsigns = true;
          indent_blankline.enabled = true;
          neo_tree = true;
          noice = true;
          which_key = true;
        };
      };
    };

    # --- Aesthetic Framework ---
    plugins = {
      web-devicons.enable = true;
      lualine.enable = true;
      treesitter.enable = true;
      dressing.enable = true;
      barbecue.enable = true;
      which-key.enable = true;

      indent-blankline = {
        enable = true;
        settings.scope.enabled = true;
      };

      bufferline = {
        enable = true;
        settings.options = {
          separator_style = "rounded";
          diagnostics = "nvim_lsp";
        };
      };

      alpha = {
        enable = true;
        theme = "dashboard";
      };

      noice = {
        enable = true;
        settings.presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
        };
      };
    };
  };
}
