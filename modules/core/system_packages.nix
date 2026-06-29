{ pkgs, inputs, ... }:

{
  environment.systemPackages =
    (with pkgs; [
      ffmpeg
      mpv
      kitty
      qimgv
      wget
      wiremix
      wl-clipboard
      p7zip

      kdePackages.ark
      kdePackages.dolphin
      kdePackages.ffmpegthumbs
      kdePackages.kio-extras
      kdePackages.konsole
      kdePackages.plasma-workspace
      kdePackages.qtsvg
      kdePackages.dolphin-plugins
    ])
    ++ [
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      configure.customLuaRC = ''
        vim.opt.tabstop = 2      -- Number of spaces that a <Tab> counts for
        vim.opt.shiftwidth = 2   -- Size of an indent
        vim.opt.expandtab = true -- Use spaces instead of tabs
        vim.opt.softtabstop = 2  -- Number of spaces a <Tab> counts for while editing
      '';
    };
    nano.enable = false;
  };

  xdg = {
    terminal-exec = {
      enable = true;
      settings.default = [ "kitty.desktop" ];
    };
    mime = {
      enable = true;
      defaultApplications = {
        "image/*" = "qimgv.desktop";
        "video/*" = "mpv.desktop";
        "application/zip" = "org.kde.ark.desktop";
        "application/x-7z-compressed" = "org.kde.ark.desktop";
        "application/x-rar" = "org.kde.ark.desktop";
      };
    };
  };

}
