{
  services.flatpak = {
    enable = true;
    update.onActivation = true;
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
  };
}
