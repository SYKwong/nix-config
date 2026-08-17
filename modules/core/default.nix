{
  imports = [
    ./boot.nix
    ./flakpak.nix
    ./fonts.nix
    ./fwupd.nix
    ./hardware.nix
    ./kernel.nix
    ./keyring.nix
    ./networking.nix
    ./networkshare.nix
    ./no_password_rebuild.nix
    ./security.nix
    ./shell.nix
    ./ssh.nix
    ./stylix.nix
    ./system.nix
    ./system_packages.nix
    ./twingate.nix
    ./usb_drive.nix
    ./user.nix
    ./zram.nix
  ];

  system.stateVersion = "26.05";
}
