{
  imports = [
    ./framework16-lvm-luks.nix
    ./impermanence.nix
    ./hardware-configuration.nix
    ./luks.nix
    ./zram.nix

    ./modules/framework 
    ./modules/lanzaboote
  ];

  system.stateVersion = "26.05";
  boot.resumeDevice = "/dev/mapper/pool-swap";
}
