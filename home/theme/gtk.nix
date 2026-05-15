{ pkgs, ... }:

{
  gtk = {
    enable = true;
    colorScheme = null;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  }; 
}
