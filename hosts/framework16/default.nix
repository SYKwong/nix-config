{ username, ... }:

{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./luks.nix
    ./zram.nix

    ../../modules/framework
    ../../modules/lanzaboote
  ];

  system.stateVersion = "26.05";
  nix.settings.trusted-users = [ username ];
  security.sudo.extraRules = [
  {
    users = [ username ];
    commands = [
      {
        command = "/run/current-system/sw/bin/nixos-rebuild";
        options = [ "NOPASSWD" ];
      }
    ];
  }
  ];

  hardware.keyboard.qmk.enable = true;
}
