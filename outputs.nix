inputs:

let
  inherit (inputs) 
  nixpkgs nixpkgs-stable 
  home-manager 
  nixos-hardware 
  disko 
  stylix 
  lanzaboote
  impermanence
  ;

  hosts = {
    framework16 = { 
      username = "fw16-kyle";
      extraModules = [
        nixos-hardware.nixosModules.framework-16-7040-amd
        lanzaboote.nixosModules.lanzaboote
        impermanence.nixosModules.impermanence
      ];
    };
  };

in {
  # Expose hosts for Bash
  hostInfo = hosts;

  nixosConfigurations = nixpkgs.lib.mapAttrs (name: info: 
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { 
          inherit inputs; 
          inherit (info) username;
          hostname = name;
        };

      modules = [
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
        stylix.nixosModules.stylix

        ./modules/core
        ./modules/home-manager
        ./modules/hyprland
        ./modules/wireless

        ./hosts/${name}

      ] ++ info.extraModules;
    }
  ) hosts;
}
