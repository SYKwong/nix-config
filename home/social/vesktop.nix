{
  programs.vesktop = {
    enable = true;
    vencord = {
      settings = {
        useQuickCss = true;
        plugins = {
          MessageLogger = {
            enabled = true;
            ignoreSelf = true;
          };
          FakeNitro.enabled = true;
        };
      };
      extraQuickCss = ''
        @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha-mauve.theme.css");
      '';
    };
  };
  stylix.targets.vesktop.enable = false;
}
