{ pkgs, ... }:

{
  imports = [
    ../hypridle.nix
    ../hyprlock.nix
    ../hyprpaper.nix
    ../kb-light-manager.nix
    ../notifications.nix
    ../rofi.nix
    ../swayosd.nix
    ../waybar.nix
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  environment.systemPackages = with pkgs; [
    hyprpolkitagent
    grim slurp satty
  ];

}
