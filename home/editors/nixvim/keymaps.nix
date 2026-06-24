{
  programs.nixvim = {
    globals.mapleader = " ";

    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<cr>";
        options.desc = "Toggle Explorer";
      }
      {
        mode = "n";
        key = "<S-h>";
        action = "<cmd>BufferLineCyclePrev<cr>";
        options.desc = "Prev Tab";
      }
      {
        mode = "n";
        key = "<S-l>";
        action = "<cmd>BufferLineCycleNext<cr>";
        options.desc = "Next Tab";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = "<cmd>bdelete<cr>";
        options.desc = "Delete Buffer";
      }
      {
        mode = "n";
        key = "<leader>l";
        action = "<cmd>bnext<CR>";
        options.desc = "Next editor tab";
      }
      {
        mode = "n";
        key = "<leader>h";
        action = "<cmd>bprevious<CR>";
        options.desc = "Previous editor tab";
      }
      {
        mode = "n";
        key = "<leader>w";
        action = "<cmd>Bdelete<CR>";
        options = {
          silent = true;
          desc = "Close current editor tab (preserve layout)";
        };
      }
      {
        mode = "n";
        key = "<leader>v";
        action = "<cmd>vsplit<CR>";
        options.desc = "Split window side-by-side";
      }
      {
        mode = "n";
        key = "<leader>s";
        action = "<cmd>split<CR>";
        options.desc = "Split window top-and-bottom";
      }
      {
        mode = "n";
        key = "<leader>H";
        action = "<C-w>h";
        options.desc = "Go to left window";
      }
      {
        mode = "n";
        key = "<leader>J";
        action = "<C-w>j";
        options.desc = "Go to bottom window";
      }
      {
        mode = "n";
        key = "<leader>K";
        action = "<C-w>k";
        options.desc = "Go to top window";
      }
      {
        mode = "n";
        key = "<leader>L";
        action = "<C-w>l";
        options.desc = "Go to right window";
      }
    ];
  };
}
