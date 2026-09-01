{
  inputs,
  username,
  hostname,
  localLLM,
  ...
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    extraSpecialArgs = {
      inherit
        inputs
        username
        hostname
        localLLM
        ;
    };

    users."${username}" =
      { ... }:
      {
        imports = [ ../../hosts/${hostname}/home.nix ];

        home.username = username;
        home.homeDirectory = "/home/${username}";
      };
  };
}
