{
  programs = {
    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    gamescope = {
      enable = true;
      enableWsi = true;
    };
  };

  services.flatpak = {
    packages = [
      "com.github.Matoking.protontricks"
      "net.davidotek.pupgui2" # protonup-qt
    ];
    overrides = {
      "com.github.Matoking.protontricks" = {
        Context = {
          filesystems = [
            "~/.steam"
          ];
        };
      };
    };
  };
}
