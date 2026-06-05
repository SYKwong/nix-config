inputs:

let
  inherit (inputs)
    nixpkgs
    nixpkgs-stable
    home-manager
    nixos-hardware
    disko
    stylix
    lanzaboote
    ;

  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};

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

in
{
  # Expose hosts for Bash
  lib.hostInfo = hosts;
  formatter.${system} = pkgs.nixfmt-tree;

  nixosConfigurations = nixpkgs.lib.mapAttrs (
    name: info:
    nixpkgs.lib.nixosSystem {
      system = system;
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
        ./modules/display-manager
        ./modules/window-manager
        ./modules/shell-scripts
        ./modules/wireless
        ./modules/virtualization
        ./modules/input
        ./modules/misc

        ./overlays

        ./hosts/${name}

      ]
      ++ info.extraModules;
    }
  ) hosts;
}
