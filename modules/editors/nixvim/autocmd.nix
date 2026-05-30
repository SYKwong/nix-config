{
  programs.nixvim.autoCmd = [
    # 1. Dynamic Code-Boundary Underline Highlight Tracking
    {
      event = [ "CursorMoved" "CursorMovedI" "BufEnter" ];
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

    # 2. Maximize Kitty Terminal Blur on Launch
    {
      event = [ "VimEnter" ];
      callback.__raw = ''
        function()
          local window_id = os.getenv("KITTY_WINDOW_ID")
          if window_id then
            local cmd = string.format("kitty @ set-background-opacity -m id:%s 0.9", window_id)
            vim.fn.system(cmd)
          end
        end
      '';
    }

    # 3. Restore Default Subtle Kitty Terminal Blur on Exit
    {
      event = [ "VimLeave" ];
      callback.__raw = ''
        function()
          local window_id = os.getenv("KITTY_WINDOW_ID")
          if window_id then
            local cmd = string.format("kitty @ set-background-opacity -m id:%s 0.75", window_id)
            vim.fn.system(cmd)
          end
        end
      '';
    }
  ];
}
