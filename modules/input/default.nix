{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      waylandFrontend = true;
      ignoreUserConfig = true; # Required for using the following settings
      addons = with pkgs; [
        fcitx5-mozc
        kdePackages.fcitx5-chinese-addons
        fcitx5-table-extra
      ];

      settings = {
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "quick-classic";
          "Groups/0/Items/2".Name = "mozc";
        };

        globalOptions = {
          "Hotkey/TriggerKeys" = {
            "0" = "Alt+Shift+Shift_L";
          };
        };

        addons = {
          classicui.globalSection = {
            Theme = "default-dark";
            VerticalCandidateList = "False";
            Font = "Sans 15";
            MenuFont="Sans 15";
            TrayFont="Sans Bold 15";
          };

          punctuation.globalSection = {
            Enabled = "False";
          };
        };
      };
    };
  };
}
