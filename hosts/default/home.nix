{
  imports = [ 
    ./../../modules/home/cli
    ./../../modules/home/browsers  

    ./alias.nix
    ./dotfile.nix
  ];

  wayland.windowManager.hyprland.systemd.enable = false;

  programs.bash = {
    enable = true;
  };
}
