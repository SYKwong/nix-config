{
  programs.nixvim.autoCmd = [
    # Dynamic Code-Boundary Underline Highlight Tracking
    {
      event = [
        "CursorMoved"
        "CursorMovedI"
        "BufEnter"
      ];
      callback.__raw = ''
        function()
          if vim.w.text_cursorline_id then
            pcall(vim.fn.matchdelete, vim.w.text_cursorline_id)
            vim.w.text_cursorline_id = nil
          end

          local current_line = vim.fn.line(".")
          local pattern = string.format([[\%%%dl\zs.*]], current_line)

          vim.w.text_cursorline_id = vim.fn.matchadd("CursorLine", pattern, -1)
        end
      '';
    }

    # Maximize Kitty Terminal Blur on Launch and Focus
    {
      event = [
        "VimEnter"
        "FocusGained"
      ];
      callback.__raw = ''
        function()
          if #vim.api.nvim_list_uis() == 0 then
            return
          end
          local window_id = os.getenv("KITTY_WINDOW_ID")
          if not window_id then
            return
          end
          vim.fn.jobstart(
            { "kitty", "@", "set-background-opacity", "-m", "id:" .. window_id, "0.95" },
            { detach = true }
          )
        end
      '';
    }

    # Restore Default Subtle Kitty Terminal Blur on Exit and Focus Lost
    {
      event = [
        "VimLeave"
        "FocusLost"
      ];
      callback.__raw = ''
        function()
          if #vim.api.nvim_list_uis() == 0 then
            return
          end
          local window_id = os.getenv("KITTY_WINDOW_ID")
          if not window_id then
            return
          end
          vim.fn.jobstart(
            { "kitty", "@", "set-background-opacity", "-m", "id:" .. window_id, "0.75" },
            { detach = true }
          )
        end
      '';
    }

    # 2 Space Tab Language
    {
      event = [ "FileType" ];
      pattern = [ "yaml" ];
      command = "setlocal tabstop=2 shiftwidth=2 softtabstop=2";
    }
  ];
}
