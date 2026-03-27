{ pkgs, ... }:

{
  programs = {
    git = {
      enable = true;
    };

    gh.enable = true;
    lazygit.enable = true;
  };
}
  


