{ pkgs, ... }: 

{
  imports = [
    ./hyprland.nix
    ./hyprlock.nix
  ];

  environment.systemPackages = with pkgs; [
    hypridle
    hyprpolkitagent
    waybar
    grim
    slurp
    kitty
    rofi
    satty
  ];
}
