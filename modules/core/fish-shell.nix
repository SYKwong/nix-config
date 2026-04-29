{ pkgs, username, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
  };  
  users.users.${username} = {
    shell = pkgs.fish;
  };
}
