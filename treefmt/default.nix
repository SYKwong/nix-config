{ lib, ... }:

let
  dir = ./.;
  files = builtins.readDir dir;

  languageModules = lib.pipe files [
    (lib.filterAttrs (name: _: name != "default.nix" && lib.hasSuffix ".nix" name))
    lib.attrNames
    (map (name: dir + "/${name}"))
  ];
in
{
  imports = languageModules;
  projectRootFile = "flake.nix";
}
