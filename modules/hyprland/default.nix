{ pkgs, ... }: 

{
  imports = [
    ./hyprland.nix
    ./hyprlock.nix
    ./walker.nix
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
