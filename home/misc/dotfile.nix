{
  config,
  username,
  ...
}:
let
  config_path = "/home/${username}/nix-config/config";
  symlink = path: config.lib.file.mkOutOfStoreSymlink "${config_path}/${path}";

  files = {
    "foot" = "foot";
    "glow" = "glow";
    "hypr" = "hypr";
    "kitty" = "kitty";

    "dolphinrc" = "kde/dolphin/dolphinrc";
    "feishin/config.json" = "feishin/config.json";
    "kservicemenurc" = "kde/dolphin/kservicemenurc";
    "qimgv/qimgv.conf" = "qimgv/qimgv.conf";
    "starship.toml" = "starship/starship.toml";
    "zen/default/chrome/zen-themes.css" = "zen/zen-themes.css";
  };

in
{
  xdg.configFile = builtins.mapAttrs (_: value: { source = symlink value; }) files;
}
