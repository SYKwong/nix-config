{ pkgs, inputs, ... }:

{
  environment = {
    systemPackages =
      (with pkgs; [
        brightnessctl
        deadnix
        ffmpeg
        glow
        jq
        kitty
        libnotify
        mpv
        p7zip
        qimgv
        qmk
        qmk_hid
        smartmontools
        statix
        wget
        wl-clipboard

        kdePackages.ark
        kdePackages.dolphin
        kdePackages.ffmpegthumbs
        kdePackages.kio-extras
      ])
      ++ [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

    etc."mpv/mpv.conf".text = ''
      autocreate-playlist=filter
    '';
  };

  programs = {
    nano.enable = false;
    localsend.enable = true;
  };

  xdg = {
    terminal-exec = {
      enable = true;
      settings.default = [ "kitty.desktop" ];
    };
    mime = {
      enable = true;
      defaultApplications = {
        "image/*" = "qimgv.desktop";
        "video/*" = "mpv.desktop";
        "application/zip" = "org.kde.ark.desktop";
        "application/x-7z-compressed" = "org.kde.ark.desktop";
        "application/x-rar" = "org.kde.ark.desktop";
      };
    };
  };

  # Enabling upower for Noctalia battery monitoring
  services.upower.enable = true;
}
