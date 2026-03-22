{

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-stable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    }

    disko = {
        url = "github:nix-community/disko/latest";
        inputs.nixpkgs.follows = "nixpkgs";
    }

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  };

  outputs = { self, nixpkgs, nixpkgs-stable,home-manager, nixos-hardware, disko, ... }:{
    nixosConfigurations.framework16 = nixpkgs.lib.nixosSystem {

      modules = [

        ./base/configuration.nix
        disko.nixosModules.disko
        ./hosts/framework16/framework16-luks.nix
        nixos-hardware.nixosModules.framework-16-7040-amd
        
        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.kyle = import ./hosts/framework16/home.nix;
            backupFileExtension = "backup";
          };
        }

      ];
    };
  };

}
