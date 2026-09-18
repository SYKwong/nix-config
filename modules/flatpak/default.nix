{
  inputs,
  lib,
  hostname,
  ...
}:

let
  hostFlatpak = ../../hosts/${hostname}/flatpak.nix;
in
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ]
  ++ lib.optional (builtins.pathExists hostFlatpak) hostFlatpak;

  services.flatpak = {
    enable = true;
    update.onActivation = true;
  };
}
