{ ... }:

{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      settings = {
        ensure_installed = [ "nix" "lua" "vimdoc" "javascript" "typescript" "python" "bash" ];
        highlight = {
          enable = true;
          additional_vim_regex_highlighting = false;
        };
      };
    };

    # --- Language Server Protocol (LSP) Engine ---
    lsp = {
      enable = true;
      servers = {
        nil_ls.enable = true;  # Nix language support
        ts_ls.enable = true;   # TypeScript & JavaScript support
        pyright.enable = true; # Python support
      };
      keymaps.lspBuf = {
        "gd" = "definition";
        "gr" = "references";
        "K" = "hover";
        "<leader>ca" = "code_action";
        "<leader>rn" = "rename";
      };
    };

    # --- Autocomplete Popup Engine (CMP) ---
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
  };
}
