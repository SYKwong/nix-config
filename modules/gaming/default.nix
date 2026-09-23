{ pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
      protontricks = {
        enable = true;
        package = pkgs.protontricks.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.imagemagick ];
          postInstall = (old.postInstall or "") + ''
            install -Dm644 ${../../icons/protontricks.svg} "$out/share/icons/hicolor/scalable/apps/protontricks.svg"
            ln -s protontricks.svg "$out/share/icons/hicolor/scalable/apps/com.github.Matoking.protontricks.svg"
            ln -s protontricks.svg "$out/share/icons/hicolor/scalable/apps/wine.svg"
            ln -s protontricks.svg "$out/share/icons/hicolor/scalable/apps/yad.svg"

            for size in 256 128 64 48 32 24 16; do
              mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps"
              magick "$out/share/icons/hicolor/scalable/apps/protontricks.svg" -resize "''${size}x''${size}" "$out/share/icons/hicolor/''${size}x''${size}/apps/protontricks.png"
              ln -s protontricks.png "$out/share/icons/hicolor/''${size}x''${size}/apps/com.github.Matoking.protontricks.png"
              ln -s protontricks.png "$out/share/icons/hicolor/''${size}x''${size}/apps/wine.png"
              ln -s protontricks.png "$out/share/icons/hicolor/''${size}x''${size}/apps/yad.png"
            done

            substituteInPlace "$out/share/applications/protontricks.desktop" \
              --replace-fail "Icon=wine" "Icon=protontricks"
            substituteInPlace "$out/share/applications/protontricks-launch.desktop" \
              --replace-fail "Icon=wine" "Icon=protontricks"
            echo "StartupWMClass=yad" >> "$out/share/applications/protontricks.desktop"
          '';
        });
      };
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    gamescope = {
      enable = true;
      enableWsi = true;
    };

    gamemode = {
      enable = true;
      settings = {
        custom = {
          start = "${pkgs.systemd}/bin/systemctl --user stop nixos-cache-warm.service 2>/dev/null || true";
        };
      };
    };
  };

  environment.systemPackages = [ pkgs.protonup-qt ];

  services.udev.packages = [ pkgs.game-devices-udev-rules ];
}
