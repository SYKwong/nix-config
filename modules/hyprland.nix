{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  environment.systemPackages = with pkgs; [
    hypridle
    hyprpolkitagent
    waybar
    grim
    slurp
    kitty
  ]
}
