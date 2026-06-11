{ inputs, ... }:

{
  imports = [ inputs.helium.homeModules.default ];

  programs.helium = {
    enable = true;

    # CLI flags passed to the browser
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--enable-features=WaylandWindowDecorations"
      "--enable-wayland-ime=true"
    ];

    # Chrome Web Store extensions (installed via Helium's privacy proxy)
    extensions = [
      { id = "ophjlpahpchlmihnnnihgmmeilfjmjjc"; } # Line
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
    ];

  };
}
