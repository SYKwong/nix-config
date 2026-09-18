{
  config,
  username,
  ...
}:
let
  config_path = "/home/${username}/nix-config/config";
  symlink = path: config.lib.file.mkOutOfStoreSymlink "${config_path}/${path}";

  files = {
    "hypr" = "hypr";

    "foot" = "foot";
    "kitty" = "kitty";
    "glow" = "glow";
    "starship.toml" = "starship/starship.toml";

    "dolphinrc" = "kde/dolphin/dolphinrc";
    "kservicemenurc" = "kde/dolphin/kservicemenurc";
    "qimgv/qimgv.conf" = "qimgv/qimgv.conf";
  };

  stateFiles = {
    "dolphinstaterc" = "kde/dolphin/dolphinstaterc";
  };
in
{
  xdg.configFile = builtins.mapAttrs (_: value: { source = symlink value; }) files;
  xdg.stateFile = builtins.mapAttrs (_: value: { source = symlink value; }) stateFiles;
}
