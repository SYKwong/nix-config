{ config, lib, pkgs, username, ... }:

{
  security.tpm2.enable = true;

  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."crypted" = {
    device = "/dev/disk/by-partlabel/disk-main-luks"; # Double check this path!
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  services.getty.autologinUser = "${username}";

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users."${username}" = {
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

