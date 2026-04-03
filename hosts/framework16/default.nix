{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./impermanence.nix
    ./luks.nix
    ./zram.nix

    ../../modules/framework
    ../../modules/lanzaboote
  ];

  system.stateVersion = "26.05";
}
