{ pkgs, inputs, ... }:

{
  environment.systemPackages =
    (with pkgs; [
      brightnessctl
      ffmpeg
      glow
      jq
      kitty
      libnotify
      p7zip
      qimgv
      qmk
      qmk_hid
      smartmontools
      wget
      wl-clipboard
      unrar

      kdePackages.ark
      kdePackages.dolphin
      kdePackages.ffmpegthumbs
      kdePackages.kio-extras
    ])
    ++ [
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

  programs = {
    nano.enable = false;
    localsend.enable = true;
  };

  # Enabling upower for Noctalia battery monitoring
  services.upower.enable = true;
}
