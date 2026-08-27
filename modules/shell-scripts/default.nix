{
  pkgs,
  hostname,
  username,
  ...
}:

let
  config_path = "/home/${username}/nix-config";

  common = {
    inherit
      pkgs
      hostname
      username
      config_path
      ;
  };

  scripts = {
    update-system = import ./update-system.nix common;
    rebuild-system = import ./rebuild.nix common;
  };
in
{
  imports = [
    ./tui-wrap.nix
  ];

  environment.systemPackages = builtins.attrValues scripts;
}
