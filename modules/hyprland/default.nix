{ ... }: 

{
  imports = [
    ./hyprland.nix
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
