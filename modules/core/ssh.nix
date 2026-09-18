{
  lib,
  username,
  hosts ? { },
  ...
}:

let
  keys = import ../../secrets/keys.nix;
  otherMachines = [ ];

  getHostAliases =
    name: info:
    let
      alias = lib.removeSuffix "-kyle" info.username;
      autoAliases = lib.optional (alias != name && alias != "") alias;
    in
    lib.unique (autoAliases ++ (info.aliases or [ ]));

  hostConfigs = lib.concatLines (
    lib.mapAttrsToList (name: info: ''
      Host ${
        lib.concatStringsSep " " (
          [
            name
            "${name}.local"
          ]
          ++ (getHostAliases name info)
        )
      }
        User ${info.username}
    '') hosts
  );

  knownHostEntries = lib.mapAttrs (name: key: {
    publicKey = key;
    extraHostNames = [
      "${name}.local"
    ]
    ++ (lib.optionals (hosts ? ${name}) (getHostAliases name hosts.${name}));
  }) keys.systems;
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

  users.users.root.openssh.authorizedKeys.keys = builtins.attrValues keys.users ++ otherMachines;

  programs.ssh = {
    extraConfig = hostConfigs;

    knownHosts = knownHostEntries;
  };
}
