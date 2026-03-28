{ pkgs, ... }:

{
programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "mtime";
        sort_dir_first = true;
      };
    };
  };
}
