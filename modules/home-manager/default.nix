{
  specialArgs,
  username,
  hostname,
  ...
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    extraSpecialArgs = specialArgs;

    users."${username}" =
      { ... }:
      {
        imports = [ ../../hosts/${hostname}/home.nix ];

        home.username = username;
        home.homeDirectory = "/home/${username}";
      };
  };
}
