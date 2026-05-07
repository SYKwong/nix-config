{ pkgs, username, ... }:

{
  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "${username}";
          email = "${username}@example.com";
        };

        init.defaultBranch = "main";
        merge.conflictstyle = "zdiff3";
        push.default = "simple";
        push.autoSetupRemote = true;
        help.autocorrect = 10;
        rerere.enabled = true;
        pull.rebase = true;
        alias = {
          co = "checkout";
          cm = "commit -m";
          pl = "pull";
          ps = "push";
          st = "status";
          lazy = "!f() { git add -A && git commit -m \"$1\" && git push; }; f";
        };
      };
    };

    gh.enable = true;
    lazygit.enable = true;
  };
  home.packages = [ pkgs.glab ];
}

