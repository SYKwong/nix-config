{
  security.tpm2.enable = true;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."crypted" = {
    device = "/dev/disk/by-partlabel/disk-main-luks";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
}
