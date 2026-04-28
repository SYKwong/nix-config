{ lib, config, username, ... }:

{
  programs = {
    fish.enable = true;

    starship = {
      enable = true;
      enableFishIntegration = true;
      
      enableTransience = true;
      settings = builtins.fromTOML (builtins.readFile ../../config/starship/starship.toml);
    };
  };
  stylix.targets.starship.enable = false;
}
