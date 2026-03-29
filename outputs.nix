inputs:

let
  inherit (inputs) nixpkgs nixpkgs-stable home-manager nixos-hardware disko stylix lanzaboote walker;

  hosts = {
      fw16 = { username = "fw16-kyle"; hostname = "framework16"; };
  };

in {
  nixosConfigurations.framework16 = nixpkgs.lib.nixosSystem {
    specialArgs = { 
      inherit inputs lanzaboote;
      inherit (hosts.fw16) username hostname;
    };

    modules = [
      ./hosts/framework16
      ./modules/core
      ./modules/framework
      ./modules/home-manager
      ./modules/lanzaboote
      ./modules/wireless/bluetooth.nix
      ./modules/wireless/wifi.nix
      ./modules/hyprland

      disko.nixosModules.disko
      home-manager.nixosModules.home-manager
      lanzaboote.nixosModules.lanzaboote
      nixos-hardware.nixosModules.framework-16-7040-amd
      stylix.nixosModules.stylix
      walker.nixosModules.default
    ];
  };
}

