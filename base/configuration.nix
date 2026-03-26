{ config, lib, pkgs, username, ... }:

{
  security.tpm2.enable = true;

  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."crypted" = {
    device = "/dev/disk/by-partlabel/disk-main-luks";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  services.getty.autologinUser = "${username}";

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
  };


  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    neovim
    wget
    tree
  ];

  system.stateVersion = "25.11";

}

