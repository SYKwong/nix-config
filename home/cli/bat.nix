{ pkgs, lib, ... }:

{
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      style = "full";
      theme = lib.mkForce "Catppuccin Mocha";
    };
    extraPackages = with pkgs.bat-extras; [
      batman
      batpipe
      batgrep
    ];
  };

  home.sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
  };

  home.shellAliases = {
      cat = "bat";
  };

}

