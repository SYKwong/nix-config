{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    hyprpolkitagent
  ];
}
