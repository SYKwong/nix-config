{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
    wget
    wiremix
    wl-clipboard
  ];

  programs = {
	  neovim = {
	    enable = true;
        defaultEditor = true;
        vimAlias = true;
	      viAlias = true;
	      configure.customLuaRC = ''
          vim.opt.tabstop = 2      -- Number of spaces that a <Tab> counts for
          vim.opt.shiftwidth = 2   -- Size of an indent
          vim.opt.expandtab = true -- Use spaces instead of tabs
          vim.opt.softtabstop = 2  -- Number of spaces a <Tab> counts for while editing
        '';
  	};
	  nano.enable = false;
  };

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "kitty.desktop" ];
  };

}
