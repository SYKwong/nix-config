{ username, ... }:

let
  keys = import ../../secrets/keys.nix;
  otherMachines = [ ];
in
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users."${username}".openssh.authorizedKeys.keys =
    builtins.attrValues keys.users ++ otherMachines;
}
