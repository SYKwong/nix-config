{
  xdg = {
    terminal-exec = {
      enable = true;
      settings.default = [ "kitty.desktop" ];
    };
    mime = {
      enable = true;
      defaultApplications = {
        "audio/*" = "io.bassi.Amberol.desktop";
        "image/*" = "qimgv.desktop";
        "video/*" = "mpv.desktop";
        "application/zip" = "org.kde.ark.desktop";
        "application/x-7z-compressed" = "org.kde.ark.desktop";
        "application/x-rar" = "org.kde.ark.desktop";
      };
    };
  };
}
