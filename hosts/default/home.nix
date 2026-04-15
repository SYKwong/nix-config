{
  imports = [ 
    ./../../home/browsers
    ./../../home/cli

    ./alias.nix
    ./dotfile.nix
  ];

  wayland.windowManager.hyprland.systemd.enable = false;

  programs.bash = {
    enable = true;
  };
}
