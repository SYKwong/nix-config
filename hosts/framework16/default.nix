{
  imports = [
    #./framework16-luks.nix
    ./framework16-lvm-luks.nix
    ./impermanence.nix
    ./hardware-configuration.nix
    ./luks.nix
    ./zram.nix
  ];

  system.stateVersion = "26.05";
  boot.resumeDevice = "/dev/mapper/pool-swap";
}
