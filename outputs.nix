inputs:

let
  inherit (inputs) nixpkgs;

  hosts = {
    framework16 = {
      username = "fw16-kyle";

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

  formatter.x86_64-linux =
    (inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.x86_64-linux ./treefmt)
    .config.build.wrapper;

  nixosConfigurations = nixpkgs.lib.mapAttrs (
    name: info:
    nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        inherit (info) username;
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
        ./modules/sunshine
        ./modules/vpn
        ./modules/wireless

        ./overlays

        ./hosts/${name}

      ]
      ++ info.extraModules;
    }
  ) hosts;
}
