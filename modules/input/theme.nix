{
  pkgs,
  ...
}:

let
  mozcSmallIcons = pkgs.stdenvNoCC.mkDerivation {
    pname = "mozc-small-icons";
    version = "1";

    dontUnpack = true;
    nativeBuildInputs = [ pkgs.imagemagick ];

    installPhase = ''
      for size in 16 22 24; do
        mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps

        convert \
          ${pkgs.fcitx5-mozc}/share/icons/hicolor/128x128/apps/fcitx_mozc.png \
          -resize ''${size}x''${size} \
          $out/share/icons/hicolor/''${size}x''${size}/apps/fcitx_mozc.png
      done
    '';
  };

in
{
  environment.systemPackages = [ mozcSmallIcons ];
}
