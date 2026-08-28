{
  imports = [
    ./boot.nix
    ./flakpak.nix
    ./fonts.nix
    ./hardware.nix
    ./kernel.nix
    ./keyring.nix
    ./networking.nix
    ./no_password_rebuild.nix
    ./security.nix
    ./shell.nix
    ./splash_screen.nix
    ./ssh.nix
    ./stylix.nix
    ./system.nix
    ./system_packages.nix
    ./usb_drive.nix
    ./user.nix
    ./zram.nix
  ];

  nix.settings.warn-dirty = false;
  system.stateVersion = "26.05";
  documentation.nixos.enable = false;
}
