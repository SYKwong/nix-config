{
  programs.nixvim = {
    plugins.toggleterm = {
      enable = true;
      settings = {
        open_mapping = "[[<Nop>]]";
        direction = "horizontal";
        size = 15;

        start_in_insert = true; # Automatically enter insert mode when opened (ready to type)
        persist_size = true; # Keeps the window size uniform if you resize it
        close_on_exit = true; # Closes the Neovim split automatically when the shell exits
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>t";
        action = "<cmd>ToggleTerm<CR>";
        options.desc = "Toggle GUI Terminal";
      }
      {
        mode = "t";
        key = "<Esc>";
        action = "<C-\\><C-n>";
        options.desc = "Normal mode inside terminal";
      }
      {
        mode = "t";
        key = "<C-h>";
        action = "<Cmd>wincmd h<CR>";
        options.desc = "Move left from terminal";
      }
      {
        mode = "t";
        key = "<C-j>";
        action = "<Cmd>wincmd j<CR>";
        options.desc = "Move down from terminal";
      }
      {
        mode = "t";
        key = "<C-k>";
        action = "<Cmd>wincmd k<CR>";
        options.desc = "Move up from terminal";
      }
      {
        mode = "t";
        key = "<C-l>";
        action = "<Cmd>wincmd l<CR>";
        options.desc = "Move right from terminal";
      }
    ];
  };
}
