{
  security.tpm2.enable = true;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."crypted".crypttabExtraOpts = [ "tpm2-device=auto" ];
}
