{
  programs.nixvim.plugins = {
    # Automatic bracket/quote pairing
    nvim-autopairs.enable = true;

    # Smart case manipulation utilities (camelCase, snake_case, etc.)
    text-case.enable = true;

    # Sidebar Git status signs in the gutter
    gitsigns.enable = true;

    # File Tree Explorer
    neo-tree = {
      enable = true;
      settings = {
        enable_git_status = true;
        window.width = 30;
      };
    };

    # Project Fuzzy Finder
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
  };
}
