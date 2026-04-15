{ username, ... }:

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
      };
    };

    gh.enable = true;
    lazygit.enable = true;

  };
}

