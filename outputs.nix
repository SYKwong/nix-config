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
  pkgs-stable = nixpkgs-stable.legacyPackages.${system};
  treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt;

  hosts = {
    framework16 = {
      username = "fw16-kyle";
      localLLM = true;
      iGPUOnly = true;
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
        inherit inputs pkgs-stable;
        inherit (info) username localLLM iGPUOnly;
        hostname = name;
      };

      modules = [
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
        stylix.nixosModules.stylix
        nix-flatpak.nixosModules.nix-flatpak
        agenix.nixosModules.default

        ./modules/core

        ./modules/ai
        ./modules/display-manager
        ./modules/gaming
        ./modules/home-manager
        ./modules/input
        ./modules/media
        ./modules/misc
        ./modules/secrets
        ./modules/shell-scripts
        ./modules/vpn
        ./modules/window-manager
        ./modules/wireless

        ./overlays

        ./hosts/${name}

      ]
      ++ info.extraModules;
    }
  ) hosts;
}
