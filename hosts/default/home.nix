{
  imports = [ 
    ./../../home/browsers
    ./../../home/cli
    ./../../home/theme
    ./../../home/shell
    ./../../home/core

    ./alias.nix
    ./dotfile.nix
    ./hide-desktop-entry.nix
    ./add-desktop-entry.nix
  ];

  wayland.windowManager.hyprland.systemd.enable = false;

  programs.fish = {
    enable = true;
  };
}
