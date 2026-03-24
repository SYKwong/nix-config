{ config, pkgs, username, ... }:

{
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  wayland.windowManager.hyprland.systemd.enable = false;

  programs.git.enable = true;
  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos, btw";
    };
    profileExtra = ''
      if uwsm check may-start && uwsm select; then
	      exec uwsm start default
      fi
    '';
  };
}
