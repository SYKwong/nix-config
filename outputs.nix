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
    treefmt-nix
    nix-flatpak
    agenix
    ;

  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
  treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt;

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
  formatter.${system} = treefmtEval.config.build.wrapper;

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
        nix-flatpak.nixosModules.nix-flatpak
        agenix.nixosModules.default

        ./modules/core

        ./modules/display-manager
        ./modules/gaming
        ./modules/home-manager
        ./modules/input
        ./modules/misc
        ./modules/shell-scripts
        ./modules/window-manager
        ./modules/wireless
        ./modules/secrets

        ./overlays

        ./hosts/${name}

      ]
      ++ info.extraModules;
    }
  ) hosts;
}
