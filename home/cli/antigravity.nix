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
        "command(git stash list)"
        "command(git stash show)"
        "command(git stash push)"
        "command(git merge-base)"
        "command(git tag)"
        "command(git describe)"
        "command(git shortlog)"

        "command(nix flake check)"
        "command(nix flake show)"
        "command(nix flake metadata)"
        "command(nix fmt)"
        "command(nix eval)"
        "command(nix path-info)"
        "command(nix build)"
        "command(nix search)"
        "command(nix-instantiate)"
        "command(nh search)"

        "command(statix check)"
        "command(deadnix)"
        "command(bash -n)"

        "command(hyprctl)"
        "command(notify-send)"
        "command(noctalia)"

        "command(ls)"
        "command(cat)"
        "command(grep)"
        "command(rg)"
        "command(find)"
        "command(fd)"
        "command(tree)"
        "command(head)"
        "command(tail)"
        "command(stat)"
        "command(file)"
        "command(strings)"
        "command(string)"
        "command(nm)"
        "command(wc)"
        "command(sort)"
        "command(uniq)"
        "command(diff)"
        "command(jq)"
        "command(which)"
        "command(awk)"
        "command(sed)"
        "command(cut)"
        "command(tr)"
        "command(echo)"
        "command(printf)"
        "command(date)"
        "command(env)"
        "command(basename)"
        "command(dirname)"
        "command(realpath)"
        "command(readlink)"
        "command(mktemp)"

        "command(df)"
        "command(du)"
        "command(free)"
        "command(lsblk)"
        "command(uname)"
        "command(uptime)"
        "command(lscpu)"
        "command(lspci)"
        "command(lsusb)"
        "command(ip)"
        "command(rfkill)"
        "command(powerprofilesctl)"
        "command(systemctl status)"
        "command(systemctl is-active)"
        "command(journalctl)"

        "write_file(/home/${username}/nix-config)"
        "write_file(/home/${username}/Projects)"
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
        "/home/${username}/Projects"
      ];
    };

    context.GEMINI = ''
      # User Preferences & Workflow Guidelines

      ## Communication Style
      - Keep responses concise, direct, and technical.
      - Provide clickable markdown links with `file://` scheme for modified files and code symbols.
      - Desktop Notifications: When completing a task or waiting for user input, check if the active terminal window is currently focused via `hyprctl activewindow`. If the user is not focused on the terminal window, send a desktop notification using `notify-send -a 'Antigravity' 'Antigravity' '<summary>'`.

      ## Git & Workflow
      - Main Branch Protection: Never commit or push directly to `main`. Always create a feature or fix branch for any code changes.
      - Branching: If currently on `main`, automatically create and switch to a new branch for the task without asking for permission. If on another branch, ask the user whether to branch from the current branch or from `main`. If there are staged or unstaged changes, proactively ask the user if they should be stashed before switching or branching.
      - Branch Housekeeping: When on `main` (e.g. at the start of a new task after switching back), automatically prune local branches whose upstream tracking remotes were deleted or merged (including squashed MRs where `git branch -vv` reports `[origin/...: gone]`), using `git branch -D` when necessary. Never delete active local branches that have unmerged work or active remotes.
      - Control: The user handles git commits, MR/PR creation, and merging manually. The agent should only prepare code changes, run formatters/linters, and suggest single-line commit messages unless explicitly instructed.
      - Commit messages: Strictly single-line Conventional Commits (e.g. `feat(...): ...`, `fix(...): ...`). Always base the commit message on the full `git diff` of all prepared changes, never just the latest incremental edit. Keep extended details for the MR/PR description.
      - Commit Workflow: Prefer the repo's `git lazy "<commit message>"` alias when suggesting staging, commit, and push steps.
      - Dependencies: `flake.lock` is managed strictly by CI; do not update or modify locks locally unless `flake.nix` was modified.

      ## NixOS & Code Conventions
      - Formatting: Format Nix code with `nix fmt`.
      - Linting & Evaluation: Verify Nix changes with `statix check`, `deadnix`, and flake evaluation (`nix flake check --no-build`). Do not run `nix flake check` if changes do not touch `.nix` files, unless a modified file is directly referenced or imported by a `.nix` file (e.g. `starship.toml`).
      - Hardware files: Never edit auto-generated `hardware-configuration.nix` files (ignore any linter warnings inside them).
      - Portability & Modularity: Avoid hardcoded numeric UIDs/GIDs (prefer dynamic `username` and `users` group). Keep host-specific logic in `hosts/<name>/` and reusable features in `modules/<category>/`.
      - Code Locality, Constants & Helpers: Avoid hoisting constants or helper functions to distant file headers. Assign magic numbers to named constant variables declared as late and locally as possible. Place private helper functions physically as close as possible to the consumers that use them (e.g. immediately preceding the calling function) to preserve local reading context.
      - Minimal Diff Churn: Do not reorder, move, or refactor unrelated functions or code blocks unless explicitly requested or necessary for functionality.
      - Guard Clauses & Early Returns: Prefer early returns / guard clauses over deep nesting or trailing else blocks to keep execution flow flat.
      - Variable Naming: Prefer clear, descriptive, and verbose variable names over terse abbreviations (e.g. `logical_monitor_width` instead of `mon_w`).
      - Hyprland Lua Conventions: Use standard `function table.name()` syntax instead of anonymous assignments (`table.name = function()`). Keybinding action helpers in `utils.lua` should return callback closures rather than raw command strings.
      - Desktop Shell: The environment uses Noctalia; legacy Waybar/sway-specific tools and derivations should be pruned when encountered.

      ## File Operations
      - File Creation and Modification: Always use `write_to_file` or `replace_file_content` to create or edit files in the workspace. Never use `cat << 'EOF' > ...` or shell redirection in `run_command`, as shell redirection triggers CLI permission prompts.

      ## Provisioning & Installation Scripts (install.sh, post-install.sh)
      - Hands-off by Default: Host onboarding and setup scripts must run unattended/non-interactively by default. Interactive setup steps (e.g. service logins) must be opt-in behind flags (e.g. `--auth`).
      - Intent & Prompts: When an explicit setup flag is passed, proceed directly without redundant per-service confirmation prompts (`[Y/n]`), using non-interactive CLI flags where available (e.g., `glab auth login --web`).
      - No Redundant PATH Checks: Avoid defensive `command -v` checks in onboarding scripts for tools declaratively managed via NixOS / Home Manager.

      ## Persisting Useful Workflow Improvements
      - Autonomous Edits Prohibited: If discovering a command, permission, workflow, or instruction during a task that would likely benefit future tasks, do not modify `antigravity.nix` or workflow guidelines automatically.
      - Protocol:
        1. Finish the current task first.
        2. Identify the improvement discovered.
        3. Explain why it would be useful for future tasks.
        4. Ask the user whether they want to persist the improvement.
        5. If approved:
           - For command permissions, propose the exact `antigravity.nix` entry.
           - For behavioral/workflow instructions, propose the exact `context.GEMINI` change.
        6. Only make the change after explicit user approval.
      - Example: "I noticed that `nm` is useful for inspecting binaries during these tasks. Would you like me to add `command(nm)` to `antigravity.nix` so I can use it automatically in future tasks?"
      - Discretion: Do not ask about every command used during a task. Only suggest persisting something when it is reasonably likely to be useful across future tasks.
    '';
  };
}
