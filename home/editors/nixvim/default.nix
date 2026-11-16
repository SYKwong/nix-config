{ inputs, lib, ... }:

let
  languageDir = ./language;
  languageFiles = lib.pipe (builtins.readDir languageDir) [
    (lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name))
    lib.attrNames
    (map (file: languageDir + "/${file}"))
  ];
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

    dependencies = {
      fd.enable = true;
      ripgrep.enable = true;
    };
  };
}
