# hosts/installer/outputs.nix
#
# Exposes `install-nixos` as flake `packages` and `apps` outputs.
#
# Architectural Rationale:
# - Custom Installer ISO: `install-nixos` is pre-baked into `$PATH` via
#   `environment.systemPackages` in `./default.nix`.
# - Generic NixOS Live Media: For bootstrapping on third-party or official minimal
#   media without our custom ISO, these flake outputs allow instant execution via:
#     `nix run .#install-nixos -- <args>` (or `nix run . -- <args>`)
# - Root Cleanliness & CI Scoping: Encapsulating this in `hosts/installer/` keeps
#   root `outputs.nix` down to a single clean `inherit` and scopes workflow push
#   triggers strictly to `hosts/installer/**`.

{
  nixpkgs,
  system ? "x86_64-linux",
}:

let
  pkgs = nixpkgs.legacyPackages.${system};
  installNixos = pkgs.callPackage ./install-nixos.nix { };

  app = {
    type = "app";
    program = "${installNixos}/bin/install-nixos";
    meta.description = "Automated NixOS host provisioning and installer script";
  };
in
{
  packages.${system}.install-nixos = installNixos;

  apps.${system} = {
    install-nixos = app;
    default = app;
  };
}
