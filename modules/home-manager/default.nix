{ inputs, username, hostname, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    
    extraSpecialArgs = { inherit inputs username hostname; };
    
    users."${username}" = { ... }: {
      imports = [../../hosts/${hostname}/home.nix];

      home.username = username;
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "26.05"; 
    };
  };
}

