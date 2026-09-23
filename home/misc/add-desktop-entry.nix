{
  xdg.desktopEntries = {
    Line = {
      name = "Line";
      exec = "helium --app=\"chrome-extension://ophjlpahpchlmihnnnihgmmeilfjmjjc/index.html#/\"";
      icon = ../../icons/Line.png;
      terminal = false;
    };

    # Force XWayland: nordvpn-gui is a Flutter app that ignores GTK_CSD=0 under Wayland,
    # rendering an unconfigurable in-app custom titlebar that conflicts with tiling/compositor rules.
    nordvpn-gui = {
      name = "NordVPN GUI";
      genericName = "VPN Client";
      comment = "NordVPN's GUI to manage vpn connection, settings, etc.";
      icon = "nordvpn";
      exec = "env GDK_BACKEND=x11 nordvpn-gui";
      categories = [ "Network" ];
    };
  };
}
