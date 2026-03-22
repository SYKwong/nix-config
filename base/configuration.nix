{ config, lib, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.getty.autologinUser = "kyle";

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.kyle = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  networking.wireless.enable = true; 

  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    neovim
    wget
    foot
    waybar
    kitty
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  system.stateVersion = "25.11";

}

