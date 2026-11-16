let
  ignoredDirs = [
    ".astro"
    ".git"
    "dist"
    "node_modules"
  ];

  escapeLuaPattern = builtins.replaceStrings [ "." ] [ "%." ];
in
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
              IblScope = { fg = colors.blue },
              IblIndent = { fg = colors.surface0 },
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
          notify = true;
          which_key = true;
        };
      };
    };

    # --- Aesthetic Framework ---
    plugins = {
      web-devicons.enable = true;
      lualine.enable = true;
      dressing.enable = true;
      barbecue.enable = true;
      gitsigns.enable = true;
      treesitter-context.enable = true;
      which-key.enable = true;

      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      indent-blankline = {
        enable = true;
        settings = {
          scope = {
            enabled = true;
            include = {
              node_type = {
                nix = [
                  "attrset"
                  "let_expression"
                  "binding"
                ];
              };
            };
          };
        };
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

      notify = {
        enable = true;
        settings.background_colour = "#000000";
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
              never_show = ignoredDirs;
              visible = true;
            };
          };
          window.width = 30;
        };
      };

      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
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
            file_ignore_patterns = builtins.concatMap (
              dir:
              let
                escaped = escapeLuaPattern dir;
              in
              [
                "^${escaped}/"
                "[/\\]${escaped}/"
              ]
              ++ (
                if dir == ".git" then
                  [
                    "^${escaped}$"
                    "[/\\]${escaped}$"
                  ]
                else
                  [ ]
              )
            ) ignoredDirs;
          };
          pickers = {
            find_files = {
              find_command = [
                "fd"
                "--type"
                "f"
                "--type"
                "l"
                "--color"
                "never"
                "--hidden"
              ]
              ++ builtins.concatMap (dir: [
                "--exclude"
                dir
              ]) ignoredDirs;
            };
            live_grep = {
              additional_args = [
                "--hidden"
              ]
              ++ map (dir: "--glob=!**/${dir}/*") ignoredDirs;
            };
          };
        };
      };
    };
  };
}
