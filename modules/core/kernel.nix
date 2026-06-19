{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;
  #boot.kernelPackages = pkgs.linuxPackages_latest;
}
