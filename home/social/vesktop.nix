{
  programs.vesktop = {
    enable = true;
    vencord = {
      settings = {
        useQuickCss = true;
      };
      extraQuickCss = ''
        @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha-mauve.theme.css");
      '';
    };
  };
  stylix.targets.vesktop.enable = false;
}
