{ pkgs, username, ... }:

{
  nix.settings.trusted-users = [ username ];
  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/nix/var/nix/profiles/system/bin/switch-to-configuration";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

}
