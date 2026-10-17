{ pkgs, username, ... }:

let
  allowRules = [
    # Git Operations
    "command(git -c core.hooksPath=/dev/null -c core.fsmonitor=false pull --ff-only origin dev)"
    "command(git -c core.hooksPath=/dev/null -c core.fsmonitor=false pull --ff-only origin develop)"
    "command(git -c core.hooksPath=/dev/null -c core.fsmonitor=false pull --ff-only origin main)"
    "command(git -c core.hooksPath=/dev/null -c core.fsmonitor=false pull --ff-only origin master)"
    "command(git add)"
    "command(git branch)"
    "command(git checkout)"
    "command(git describe)"
    "command(git diff)"
    "command(git fetch)"
    "command(git grep)"
    "command(git log)"
    "command(git ls-files)"
    "command(git ls-tree)"
    "command(git merge-base)"
    "command(git remote)"
    "command(git rev-parse)"
    "command(git rm)"
    "command(git shortlog)"
    "command(git show)"
    "command(git stash apply)"
    "command(git stash list)"
    "command(git stash pop)"
    "command(git stash push)"
    "command(git stash show)"
    "command(git status)"
    "command(git switch)"
    "command(git tag)"

    # Node & Documentation Tooling
    "command(npm audit)"
    "command(npm ci --ignore-scripts)"
    "command(npm install --package-lock-only --ignore-scripts)"
    "command(npx --no-install astro build)"

    # Nix & Flake Management
    "command(nh search)"
    "command(nix build)"
    "command(nix eval)"
    "command(nix flake check)"
    "command(nix flake metadata)"
    "command(nix flake show)"
    "command(nix fmt)"
    "command(nix path-info)"
    "command(nix search)"
    "command(nix-instantiate)"

    # Shell & Desktop Inspection
    "command(bash -n)"
    "command(hyprctl)"
    "command(noctalia)"

    # Coreutils & CLI Inspection
    "command(awk)"
    "command(basename)"
    "command(cat)"
    "command(cut)"
    "command(date)"
    "command(diff)"
    "command(dirname)"
    "command(echo)"
    "command(env)"
    "command(fd)"
    "command(file)"
    "command(find)"
    "command(grep)"
    "command(head)"
    "command(jq)"
    "command(ls)"
    "command(mktemp)"
    "command(nm)"
    "command(printf)"
    "command(readlink)"
    "command(realpath)"
    "command(rg)"
    "command(sed)"
    "command(sort)"
    "command(stat)"
    "command(string)"
    "command(strings)"
    "command(tail)"
    "command(tr)"
    "command(tree)"
    "command(uniq)"
    "command(wc)"
    "command(which)"

    # System & Hardware Metrics
    "command(df)"
    "command(du)"
    "command(free)"
    "command(ip)"
    "command(journalctl)"
    "command(lsblk)"
    "command(lscpu)"
    "command(lspci)"
    "command(lsusb)"
    "command(powerprofilesctl)"
    "command(rfkill)"
    "command(systemctl is-active)"
    "command(systemctl status)"
    "command(uname)"
    "command(uptime)"

    # Workspace Filesystem
    "write_file(/home/${username}/Projects)"
    "write_file(/home/${username}/nix-config)"
  ];

  denyRules = [
    "command((mkfs.*))"
    "command(dd)"
    "command(rm -rf /)"
    "command(rm -rf /*)"
    "command(sudo)"
    "write_file(.git/)"
    "write_file(/home/${username}/.ssh)"
  ];

  extractCommands =
    rules:
    builtins.concatMap (
      rule:
      let
        match = builtins.match "^command\\((.*)\\)$" rule;
      in
      if match != null then match else [ ]
    ) rules;

  allowedCommands = extractCommands allowRules;
  deniedCommands = extractCommands denyRules;

  pipelineAllowHook =
    pkgs.writers.writePython3Bin "agy-pipeline-allow"
      {
        flakeIgnore = [ "E501" ];
      }
      ''
        import json
        import re
        import shlex
        import sys

        ALLOWED_COMMANDS = json.loads(
            r"""${builtins.toJSON allowedCommands}"""
        )
        DENIED_COMMANDS = json.loads(
            r"""${builtins.toJSON deniedCommands}"""
        )


        def clean_segment(cmd_str):
            parts = cmd_str.strip().split()
            while parts and "=" in parts[0] and not parts[0].startswith("-"):
                parts.pop(0)
            return " ".join(parts)


        def matches_rule(cleaned_cmd, target):
            if not cleaned_cmd:
                return False
            if target.startswith("(") and target.endswith(")"):
                return bool(re.match(r"^" + target + r"(\s|$)", cleaned_cmd))
            return cleaned_cmd == target or cleaned_cmd.startswith(target + " ")


        def evaluate_command(cmd_str):
            try:
                lexer = shlex.shlex(cmd_str, posix=True, punctuation_chars="|;&><")
                lexer.whitespace_split = False
                tokens = list(lexer)
            except Exception:
                return "ask"

            if not tokens:
                return "ask"

            operators = {"|", ";", "&&", "||", ">", ">>", "<", "&"}
            segments = []
            current_segment = []
            has_non_pipe_operator = False

            for token in tokens:
                if token in operators:
                    if token != "|":
                        has_non_pipe_operator = True
                    elif not current_segment:
                        return "ask"
                    if current_segment:
                        segments.append(" ".join(current_segment))
                        current_segment = []
                else:
                    current_segment.append(token)

            if current_segment:
                segments.append(" ".join(current_segment))
            elif "|" in tokens:
                return "ask"

            for seg in segments:
                cleaned = clean_segment(seg)
                if any(matches_rule(cleaned, target) for target in DENIED_COMMANDS):
                    return "deny"

            if "`" in cmd_str or "$(" in cmd_str or "\n" in cmd_str or "\r" in cmd_str:
                return "ask"

            if has_non_pipe_operator or not segments:
                return "ask"

            if all(
                any(matches_rule(clean_segment(seg), target) for target in ALLOWED_COMMANDS)
                for seg in segments
            ):
                return "allow"

            return "ask"


        def main():
            try:
                raw = sys.stdin.read()
                if not raw.strip():
                    print(json.dumps({"decision": "ask"}))
                    return
                data = json.loads(raw)
            except Exception:
                print(json.dumps({"decision": "ask"}))
                return

            tool_call = data.get("toolCall", {})
            if tool_call.get("name") != "run_command":
                print(json.dumps({"decision": "ask"}))
                return

            cmd_line = tool_call.get("args", {}).get("CommandLine", "").strip()
            if not cmd_line:
                print(json.dumps({"decision": "ask"}))
                return

            decision = evaluate_command(cmd_line)
            if decision == "allow":
                print(json.dumps({
                    "decision": "allow",
                    "reason": "Approved command/pipeline from allowRules"
                }))
            elif decision == "deny":
                print(json.dumps({
                    "decision": "deny",
                    "reason": "Command matches denyRules"
                }))
            else:
                print(json.dumps({"decision": "ask"}))


        if __name__ == "__main__":
            main()
      '';
in
{
  programs.antigravity-cli = {
    enable = true;
    defaultModel = "gemini-3.8-flash-high";

    permissions = {
      allow = allowRules;
      deny = denyRules;

      ask = [
        "command(git commit)"
        "command(git push)"
        "command(git reset)"
        "command(git restore)"
        "command(nixos-rebuild)"
        "command(rm)"
      ];
    };

    settings = {
      notifications = true;
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

      ## Git & Workflow
      - Branch Protection: Never commit or push directly to primary trunk (`main`, `master`) or staging/pre-release branches (`dev`, `develop`). Always create a feature or fix branch for any code changes.
      - Branching: If there are staged or unstaged changes, proactively ask the user if they should be stashed before switching or branching. If the repository does not have a branching rule defined in `AGENTS.md`, prompt the user for the repository's branching rule and ask whether to persist it into `AGENTS.md` as an agent rule.
      - Branch Housekeeping: When on a primary trunk branch (`main` or `master`) (e.g. at the start of a new task after switching back), automatically prune local branches whose upstream tracking remotes were deleted or merged (including squashed MRs where `git branch -vv` reports `[origin/...: gone]`), using `git branch -D` when necessary. Never delete active local branches that have unmerged work or active remotes.
      - Control: The user handles git commits, MR/PR creation, and merging manually. The agent should only prepare code changes, run formatters/linters, and suggest single-line commit messages unless explicitly instructed.
      - Commit messages: Strictly single-line Conventional Commits (e.g. `feat(...): ...`, `fix(...): ...`). Always base the commit message on the full `git diff` of all prepared changes, never just the latest incremental edit. Keep extended details for the MR/PR description.
      - Commit Workflow: Prefer the repo's `git lazy "<commit message>"` alias when suggesting staging, commit, and push steps.
      - Pull Restrictions: Never attempt to pull on or into feature branches. Pulling from remote is strictly restricted to fast-forwarding clean local trunk branches (`main`, `master`, `dev`, `develop`) from `origin` with disabled hooks (`git -c core.hooksPath=/dev/null -c core.fsmonitor=false pull --ff-only origin <branch>`).

      ## Code Conventions
      - Code Locality, Constants & Helpers: Avoid hoisting constants or helper functions to distant file headers. Assign magic numbers to named constant variables declared as late and locally as possible. Place private helper functions physically as close as possible to the consumers that use them (e.g. immediately preceding the calling function) to preserve local reading context.
      - Minimal Diff Churn: Do not reorder, move, or refactor unrelated functions or code blocks unless explicitly requested or necessary for functionality.
      - Guard Clauses & Early Returns: Prefer early returns / guard clauses over deep nesting or trailing else blocks to keep execution flow flat.
      - Variable Naming: Prefer clear, descriptive, and verbose variable names over terse abbreviations (e.g. `logical_monitor_width` instead of `mon_w`).

      ## Command & File Operations
      - Command Execution & Pipelines: Pipelines composed exclusively of read-only inspection utilities (e.g. `git`, `grep`, `awk`, `sed`, `jq`, `head`, `tail`, `sort`, `uniq`, `wc`, `cat`, `cut`, `tr`, `find`, `fd`) are permitted and auto-approved via the pipeline PreToolUse hook. Do not chain mutating commands with `&&`, `||`, `;`, or shell redirection in `run_command`.
      - File Creation and Modification: Always use `write_to_file` or `replace_file_content` to create or edit files in the workspace. Never use `cat << 'EOF' > ...` or shell redirection in `run_command`, as shell redirection triggers CLI permission prompts.
      - Nix Store Operations: Never attempt direct filesystem reads, searches, or traversals on `/nix/store` (these are hard-locked and will block execution). Always inspect configuration options, module definitions, and package metadata declaratively via `nix eval` (e.g., `nix eval .#nixosConfigurations.<host>.options.<option>` or `nix eval .#nixosConfigurations.<host>.config.<path>`). Only if declarative evaluation fails or raw source inspection is strictly unavoidable should you trigger a store read request, providing the exact path and rationale.

      ## Persisting Useful Workflow Improvements
      - Autonomous Edits Prohibited: If discovering a command, permission, workflow, or instruction during a task that would likely benefit future tasks, do not modify `antigravity.nix`, `AGENTS.md`, or workflow guidelines automatically.
      - Protocol:
        1. Finish the current task first.
        2. Identify the improvement discovered.
        3. Explain why it would be useful for future tasks.
        4. Ask the user whether they want to persist the improvement.
        5. If approved:
           - For command permissions, propose the exact `antigravity.nix` entry.
           - For behavioral/workflow instructions, propose the exact `context.GEMINI` (global) or `AGENTS.md` (repo-specific) change.
        6. Only make the change after explicit user approval.
      - Example: "I noticed that `nm` is useful for inspecting binaries during these tasks. Would you like me to add `command(nm)` to `antigravity.nix` so I can use it automatically in future tasks?"
      - Discretion: Do not ask about every command used during a task. Only suggest persisting something when it is reasonably likely to be useful across future tasks.
    '';
  };

  home.file.".gemini/config/hooks.json".text = builtins.toJSON {
    pipeline-allow = {
      PreToolUse = [
        {
          matcher = "run_command";
          hooks = [
            {
              type = "command";
              command = "${pipelineAllowHook}/bin/agy-pipeline-allow";
              timeout = 5;
            }
          ];
        }
      ];
    };
  };
}
