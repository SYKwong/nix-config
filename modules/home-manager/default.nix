{
  lib,
  specialArgs,
  username,
  hostname,
  ...
}:

let
  hostHome = ../../hosts/${hostname}/home;
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    extraSpecialArgs = specialArgs;

    users."${username}" =
      { ... }:
      {
        imports = [
          ../../home
        ]
        ++ lib.optional (builtins.pathExists hostHome) hostHome;

        home.username = username;
        home.homeDirectory = "/home/${username}";
      };
  };
}
