{ pkgs, username, ... }:

{
  stylix.targets.lazygit.enable = true;

  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "${username}";
          email = "${username}@example.com";
        };

        # git config options
        init.defaultBranch = "main";
        branch.sort = "-committerdate";
        tag.sort = "version:refname";
        diff.algorithm = "histogram";
        diff.colorMoved = "default";
        merge.conflictstyle = "zdiff3";
        push.default = "simple";
        push.autoSetupRemote = true;
        help.autocorrect = 10;
        rerere.enabled = true;
        rerere.autoupdate = true;
        pull.rebase = true;
        fetch.prune = true;
        rebase.autoStash = true;
        merge.autoStash = true;

        alias = {
          # Formats code at the repo root if a flake formatter is configured, safely
          # ignores flakes without one (e.g. no treefmt-nix), then stages, commits, and pushes.
          # For implementation details, see docs/src/content/docs/code-quality.md.
          lazy = "!f() { top=\"$(git rev-parse --show-toplevel 2>/dev/null)\"; if [ -f \"$top/flake.nix\" ]; then out=\"$( (cd \"$top\" && nix fmt) 2>&1 )\"; res=$?; if [ $res -ne 0 ]; then case \"$out\" in *\"does not provide attribute\"*\"formatter\"*) ;; *) echo \"$out\" >&2; return 1 ;; esac; elif [ -n \"$out\" ]; then echo \"$out\"; fi; fi && git add -A && git commit -m \"$1\" && git push; }; f";
        };
      };
    };

    gh.enable = true;
    lazygit.enable = true;
  };

  home.packages = [ pkgs.glab ];
}
