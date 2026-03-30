{ pkgs, ... }: 

{
  imports = [
    ./hyprland.nix
    ./hyprlock.nix
    ./screenshot.nix
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
