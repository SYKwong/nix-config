{
  specialArgs,
  username,
  extraHomeModules ? [ ],
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
        imports = [ ../../home ] ++ extraHomeModules;

        home.username = username;
        home.homeDirectory = "/home/${username}";
      };
  };
}
