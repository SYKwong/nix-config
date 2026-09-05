{ username, ... }:

{
  programs.antigravity-cli = {
    enable = true;

    permissions = {
      allow = [
        "command(git status)"
        "command(git diff)"
        "command(git log)"
        "command(git show)"
        "command(git branch)"
        "command(git add)"
        "command(git fetch)"
        "command(git checkout)"
        "command(git switch)"
        "command(git ls-tree)"
        "command(git ls-files)"
        "command(git rev-parse)"
        "command(git remote)"

        "command(nix flake check)"
        "command(nix flake show)"
        "command(nix flake metadata)"
        "command(nix fmt)"
        "command(nix eval)"
        "command(nix path-info)"
        "command(nix build)"

        "command(statix check)"
        "command(deadnix)"

        "command(hyprctl)"

        "command(ls)"
        "command(cat)"
        "command(grep)"
        "command(find)"
        "command(head)"
        "command(tail)"
        "command(stat)"
        "command(file)"
        "command(wc)"
        "command(sort)"
        "command(uniq)"
        "command(diff)"
        "command(jq)"
        "command(which)"

        "command(df)"
        "command(du)"
        "command(free)"
        "command(lsblk)"
        "command(uname)"
        "command(systemctl status)"
        "command(systemctl is-active)"
        "command(journalctl)"

        "write_file(*)"
      ];

      deny = [
        "command(rm -rf /)"
        "command(rm -rf /*)"
        "command((mkfs.*))"
        "command(dd)"
        "command(sudo)"
        "write_file(.git/)"
        "write_file(/home/${username}/.ssh)"
      ];

      ask = [
        "command(rm)"
        "command(git rm)"
        "command(git commit)"
        "command(git push)"
        "command(git restore)"
        "command(git reset)"
        "command(nixos-rebuild)"
      ];
    };

    settings = {
      trustedWorkspaces = [
        "/home/${username}/nix-config"
      ];
    };

    context.GEMINI = ''
      # User Preferences & Workflow Guidelines

      ## Communication Style
      - Keep responses concise, direct, and technical.
      - Provide clickable markdown links with `file://` scheme for modified files and code symbols.

      ## Git & Workflow
      - Branching: Before starting a new task, proactively ask the user if they would like to create a new branch for the work (and create/switch to it if approved).
      - Control: The user handles git commits, MR/PR creation, and merging manually. The agent should only prepare code changes, run formatters/linters, and suggest single-line commit messages unless explicitly instructed.
      - Commit messages: Strictly single-line Conventional Commits (e.g. `feat(...): ...`, `fix(...): ...`). Keep extended details for the MR/PR description.
      - Dependencies: `flake.lock` is managed strictly by CI; do not update or modify locks locally.

      ## NixOS & Code Conventions
      - Formatting: Format Nix code with `nix fmt`.
      - Linting: Verify Nix changes with `statix check` and `deadnix`.
      - Hardware files: Never edit auto-generated `hardware-configuration.nix` files (ignore any linter warnings inside them).
      - Portability: Avoid hardcoded numeric UIDs/GIDs (prefer dynamic `username` and `users` group). Keep host-specific logic in `hosts/<name>/`.
    '';
  };
}
