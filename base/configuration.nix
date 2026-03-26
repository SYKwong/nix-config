{ config, lib, pkgs, username, ... }:

{
  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = true;
  
  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    loader.timeout = 0;
    plymouth.enable = true;
  };

  systemd.extraConfig = ''
    ShowStatus=no
  '';

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

