{
  imports = [ 
    ./../../home/browsers
    ./../../home/cli
    ./../../home/theme
    ./../../home/shell
    ./../../home/core
    ./../../home/social

    ./alias.nix
    ./dotfile.nix
    ./hide-desktop-entry.nix
  ];

  wayland.windowManager.hyprland.systemd.enable = false;

  programs.fish = {
    enable = true;
  };
}
