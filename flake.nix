{

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
        url = "github:nix-community/disko/latest";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  };


  outputs = { self, nixpkgs, nixpkgs-stable,home-manager, nixos-hardware, disko, ... } @ inputs : 
  let
    hosts = {
        fw16 = {name = "fw16-kyle";};
    };
  in {
    nixosConfigurations.framework16 = nixpkgs.lib.nixosSystem {
      specialArgs = { 
        inherit inputs;
        username = hosts.fw16.name; 
      };

      modules = [

        ./base/configuration.nix

        ./hosts/framework16/framework16-luks.nix
        ./hosts/framework16/hardware-configuration.nix
        ./hosts/framework16/luks.nix

        ./modules/hyprland.nix
        ./modules/wifi.nix
        ./modules/bluetooth.nix

        disko.nixosModules.disko
        nixos-hardware.nixosModules.framework-16-7040-amd

        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit inputs;
              username = hosts.fw16.name;
            };
            users."${hosts.fw16.name}" = import ./hosts/framework16/home.nix;
            backupFileExtension = "backup";

          };
        }

      ];
    };
  };

}
