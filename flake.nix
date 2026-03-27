{


  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
        url = "github:nix-community/disko/latest";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { self, nixpkgs, nixpkgs-stable,home-manager, nixos-hardware, disko, stylix, lanzaboote, ... } @ inputs : 
  let
    hosts = {
        fw16 = {name = "fw16-kyle";};
    };
  in {
    nixosConfigurations.framework16 = nixpkgs.lib.nixosSystem {
      specialArgs = { 
        inherit inputs lanzabooote 
        username = hosts.fw16.name; 
      };

      modules = [
        ./hosts/framework16

        ./modules/core
        ./modules/framework/framework-tool-tui.nix
        ./modules/wireless/bluetooth.nix
        ./modules/wireless/wifi.nix
        ./modules/hyprland.nix

        disko.nixosModules.disko
        nixos-hardware.nixosModules.framework-16-7040-amd
        stylix.nixosModules.stylix

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
