{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  
  environment.systemPackages = with pkgs; [
    hypridle
    hyprpolkitagent
    waybar
    grim
    slurp
    kitty
  ];
}
