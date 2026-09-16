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

  hosts = {
    framework16 = {
      username = "fw16-kyle";
      system = "x86_64-linux";

      extraModules = [
        nixos-hardware.nixosModules.framework-16-7040-amd
        lanzaboote.nixosModules.lanzaboote

        ./modules/framework
        ./modules/laptop
        ./modules/lanzaboote
      ];
    };

    mini-pc-k8 = {
      username = "k8-kyle";
      system = "x86_64-linux";

      extraModules = [
        nixos-hardware.nixosModules.common-cpu-amd
        nixos-hardware.nixosModules.common-cpu-amd-pstate
        nixos-hardware.nixosModules.common-gpu-amd
        nixos-hardware.nixosModules.common-pc-ssd

        ./modules/desktop
        ./modules/power/ppd.nix
      ];
    };
  };

in
{
  # Expose hosts for Bash
  lib.hostInfo = hosts;

  formatter =
    nixpkgs.lib.genAttrs (nixpkgs.lib.unique (map (host: host.system) (nixpkgs.lib.attrValues hosts)))
      (
        system: (treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt).config.build.wrapper
      );

  nixosConfigurations = nixpkgs.lib.mapAttrs (
    name: info:
    nixpkgs.lib.nixosSystem {
      inherit (info) system;
      specialArgs = {
        inherit inputs;
        inherit (info) username;
        pkgs-stable = nixpkgs-stable.legacyPackages.${info.system};
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
