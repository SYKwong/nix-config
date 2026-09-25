{ inputs, lib, ... }:

let
  languageDir = ./language;
  languageFiles = map (file: languageDir + "/${file}") (
    builtins.attrNames (
      lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name) (
        builtins.readDir languageDir
      )
    )
  );
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim

    ./autocmd.nix
    ./options.nix
    ./keymaps.nix
    ./ui.nix
    ./plugins.nix
    ./plugins-minuet.nix
    ./term.nix
  ]
  ++ languageFiles;

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
