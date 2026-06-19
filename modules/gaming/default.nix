{ pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };

  environment.systemPackages = [ pkgs.protonup-qt ];

  services.flatpak = {
    packages = [
      "com.github.Matoking.protontricks"
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
