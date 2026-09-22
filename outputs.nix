inputs:

let
  inherit (inputs) nixpkgs;

  hosts = {
    framework16 = {
      username = "fw16-kyle";
      system = "x86_64-linux";

      extraModules = [
        inputs.nixos-hardware.nixosModules.framework-16-7040-amd
        inputs.lanzaboote.nixosModules.lanzaboote

        ./modules/hardware/framework.nix
        ./modules/laptop
        ./modules/lanzaboote
      ];
    };

    mini-pc-k8 = {
      username = "k8-kyle";
      system = "x86_64-linux";

      extraModules = [
        inputs.nixos-hardware.nixosModules.common-cpu-amd
        inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
        inputs.nixos-hardware.nixosModules.common-gpu-amd
        inputs.nixos-hardware.nixosModules.common-pc-ssd

        ./modules/desktop
        ./modules/power-management/ppd.nix
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
        system:
        (inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt).config.build.wrapper
      );

  nixosConfigurations = nixpkgs.lib.mapAttrs (
    name: info:
    nixpkgs.lib.nixosSystem {
      inherit (info) system;
      specialArgs = {
        inherit inputs;
        inherit (info) username;
        pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${info.system};
        hostname = name;
      };

      modules = [
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        inputs.stylix.nixosModules.stylix
        inputs.agenix.nixosModules.default

        ./modules/core

        ./modules/ai
        ./modules/gaming
        ./modules/home-manager
        ./modules/hyprland
        ./modules/input-method
        ./modules/secrets
        ./modules/shell-scripts
        ./modules/vpn
        ./modules/wireless

        ./overlays

        ./hosts/${name}

      ]
      ++ info.extraModules;
    }
  ) hosts;
}
