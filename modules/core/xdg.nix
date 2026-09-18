{
  xdg = {
    terminal-exec = {
      enable = true;
      settings.default = [ "kitty.desktop" ];
    };
    mime = {
      enable = true;
      defaultApplications = {
        "text/*" = "nvim.desktop";
        "audio/*" = "io.bassi.Amberol.desktop";
        "image/*" = "qimgv.desktop";
        "video/*" = "mpv.desktop";
        "application/zip" = "org.kde.ark.desktop";
        "application/x-7z-compressed" = "org.kde.ark.desktop";
        "application/x-rar" = "org.kde.ark.desktop";
      };
    };
  };

  environment.etc."xdg/kdeglobals".text = ''
    [General]
    TerminalApplication=kitty
    TerminalService=kitty.desktop
  '';
}
