inputs:

let
  inherit (inputs) 
  nixpkgs nixpkgs-stable 
  home-manager 
  nixos-hardware 
  disko 
  stylix 
  lanzaboote
  silentSDDM
  ;

  hosts = {
    framework16 = { 
      username = "fw16-kyle";
      extraModules = [
        nixos-hardware.nixosModules.framework-16-7040-amd
        lanzaboote.nixosModules.lanzaboote
        
        ./modules/framework
        ./modules/laptop
        ./modules/lanzaboote
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
        silentSDDM.nixosModules.default

        ./modules/core

        ./modules/home-manager
        ./modules/window-manager/hyprland
        #./modules/window-manager/niri
        ./modules/shell-scripts
        ./modules/wireless
        ./modules/virtualization
        ./modules/input

        ./overlays

        ./hosts/${name}

      ] ++ info.extraModules;
    }
  ) hosts;
}
