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

  programs.ssh.knownHosts = {
    mini-pc-k8 = {
      publicKey = keys.systems."mini-pc-k8";
      extraHostNames = [ "mini-pc-k8.local" ];
    };
    fw16 = {
      publicKey = keys.systems.fw16;
      extraHostNames = [
        "framework16"
        "framework16.local"
      ];
    };
  };
}
