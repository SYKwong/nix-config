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
  	};
	nano.enable = false;
  };

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "kitty.desktop" ];
  };

}
