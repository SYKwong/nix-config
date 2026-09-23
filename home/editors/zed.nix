{ pkgs, ... }:

{
  stylix.targets.zed.enable = true;

  programs.zed-editor = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "zed-editor";
      paths = [ pkgs.zed-editor ];
      nativeBuildInputs = [ pkgs.imagemagick ];
      postBuild = ''
        for size in 256 128 64 48 32 24 16; do
          mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps"
          magick "$out/share/icons/hicolor/512x512/apps/zed.png" -resize "''${size}x''${size}" "$out/share/icons/hicolor/''${size}x''${size}/apps/zed.png"
          ln -s zed.png "$out/share/icons/hicolor/''${size}x''${size}/apps/dev.zed.Zed.png"
        done
        ln -s zed.png "$out/share/icons/hicolor/512x512/apps/dev.zed.Zed.png"
      '';
      meta.mainProgram = "zeditor";
    };

    extensions = [
      "nix"
      "toml"
      "make"
      "lua"
      "git-firefly"
    ];

  };
}
