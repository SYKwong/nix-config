{
  imports = [ 
    ./../../home/browsers
    ./../../home/cli
    ./../../home/theme

    ./alias.nix
    ./dotfile.nix
    ./hide-desktop-entry.nix
  ];

  wayland.windowManager.hyprland.systemd.enable = false;

  programs.fish = {
    enable = true;
  };
}
