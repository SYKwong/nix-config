{ username, ... }:

{
  nix.settings.trusted-users = [ username ];
  security.sudo = {
    extraConfig = ''
      Defaults env_keep += "SSH_AUTH_SOCK"
    '';
    extraRules = [
      {
        users = [ username ];
        commands = [
          {
            command = "/run/current-system/sw/bin/rebuild";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/nix/var/nix/profiles/system/bin/switch-to-configuration";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
