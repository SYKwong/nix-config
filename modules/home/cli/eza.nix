{ pkgs, ... }:
{
  programs.eza = {
    enable = true;
    icons = "auto";
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    git = true;

    extraOptions = [
      "--group-directories-first"
      "--no-quotes"
      "--header"
      "--git-ignore"
      "--icons=always"
      "--classify"
      "--hyperlink"
    ];
  };
  home.shellAliases = {
    ls = "eza -lh --group-directories-first";
    lt = "eza --tree --level=2";
    ll = "eza -lh --no-user --long";
    la = "eza -lah ";
    tree = "eza --tree ";
  };
}

