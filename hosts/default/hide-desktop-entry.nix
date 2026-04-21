{ lib, ... }:

let
  appsToHide = [   
  ];
in
{
  xdg.dataFile = lib.listToAttrs (map (name: {
    name = "applications/${name}.desktop";
    value = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=${name}
        Exec=true
        NoDisplay=true
      '';
    };
  }) appsToHide);
}
