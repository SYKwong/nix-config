{ pkgs, ... }: 

{
  imports = [
    ./hyprland.nix
    ./hyprlock.nix
    ./rofi.nix
  ];

  environment.systemPackages = with pkgs; [
    hypridle
    hyprpolkitagent
    waybar
    grim
    slurp
    kitty
  ];
}
