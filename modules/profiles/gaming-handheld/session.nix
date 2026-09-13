{
  pkgs,
  username,
  ...
}:

{
  # Handheld console runs Steam Gamescope session and KDE Plasma instead of Hyprland
  programs = {
    hyprland.enable = false;
    steam.gamescopeSession.enable = true;
  };

  # SDDM with Wayland, Catppuccin theme, and auto-login directly to Steam Gaming Mode by default
  services.displayManager = {
    ly.enable = false;
    defaultSession = "steam";
    autoLogin = {
      enable = true;
      user = username;
    };
    sddm = {
      enable = true;
      wayland.enable = true;
      autoLogin.relogin = true;
      theme = "catppuccin-sddm-corners";
      extraPackages = [
        pkgs.kdePackages.qt5compat
        pkgs.kdePackages.qtquick3d
        pkgs.kdePackages.qtsvg
        pkgs.kdePackages.qtvirtualkeyboard
      ];
      settings = {
        General = {
          InputMethod = "qtvirtualkeyboard";
        };
      };
    };
  };

  environment.systemPackages = [
    pkgs.catppuccin-sddm-corners
  ];

  # Allow user in users group to configure Wi-Fi directly in Steam UI
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        action.id.indexOf("org.freedesktop.NetworkManager") == 0 &&
        subject.isInGroup("users") &&
        subject.local &&
        subject.active
      ) {
        return polkit.Result.YES;
      }
    });
  '';
}
