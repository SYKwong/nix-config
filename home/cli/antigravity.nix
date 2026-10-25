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
    "command(git ls-remote)"
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
    "command(glab ci lint)"
    "command(glab ci list)"
    "command(glab ci status)"
    "command(glab ci trace)"
    "command(glab ci view)"
    "command(glab mr list)"
    "command(glab mr view)"

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
        flakeIgnore = [
          "E203"
          "E501"
          "W503"
          "W504"
        ];
      }
      ''
        import json
        import re
        import shlex
        import shutil
        import subprocess
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


        def extract_substitutions(cmd_str):
            subs = []
            i = 0
            n = len(cmd_str)
            in_single_quote = False
            in_double_quote = False

            while i < n:
                c = cmd_str[i]
                if c == "\\":
                    i += 2
                    continue
                if c == "'" and not in_double_quote:
                    in_single_quote = not in_single_quote
                    i += 1
                    continue
                if c == '"' and not in_single_quote:
                    in_double_quote = not in_double_quote
                    i += 1
                    continue

                if not in_single_quote:
                    if c == "$" and i + 2 < n and cmd_str[i + 1:i + 3] == "((":
                        start = i + 3
                        depth = 2
                        j = start
                        sub_single = False
                        sub_double = False
                        while j < n and depth > 0:
                            ch = cmd_str[j]
                            if ch == "\\":
                                j += 2
                                continue
                            if ch == "'" and not sub_double:
                                sub_single = not sub_single
                            elif ch == '"' and not sub_single:
                                sub_double = not sub_double
                            elif not sub_single and not sub_double:
                                if ch == "(":
                                    depth += 1
                                elif ch == ")":
                                    depth -= 1
                            j += 1
                        if depth == 0:
                            expr = cmd_str[start:j - 2].strip()
                            subs.append(("arith", cmd_str[i:j], expr, in_double_quote))
                            i = j
                            continue
                    elif (c == "$" or c == "<") and i + 1 < n and cmd_str[i + 1] == "(":
                        kind = "cmd" if c == "$" else "proc"
                        start = i + 2
                        depth = 1
                        j = start
                        sub_single = False
                        sub_double = False
                        while j < n and depth > 0:
                            ch = cmd_str[j]
                            if ch == "\\":
                                j += 2
                                continue
                            if ch == "'" and not sub_double:
                                sub_single = not sub_single
                            elif ch == '"' and not sub_single:
                                sub_double = not sub_double
                            elif not sub_single and not sub_double:
                                if ch == "(":
                                    depth += 1
                                elif ch == ")":
                                    depth -= 1
                            j += 1
                        if depth == 0:
                            inner_cmd = cmd_str[start:j - 1].strip()
                            subs.append((kind, cmd_str[i:j], inner_cmd, in_double_quote))
                            i = j
                            continue
                    elif c == "`":
                        start = i + 1
                        j = start
                        while j < n and cmd_str[j] != "`":
                            if cmd_str[j] == "\\":
                                j += 1
                            j += 1
                        if j < n and cmd_str[j] == "`":
                            inner_cmd = cmd_str[start:j].strip()
                            subs.append(("cmd", cmd_str[i:j + 1], inner_cmd, in_double_quote))
                            i = j + 1
                            continue
                i += 1
            return subs


        def evaluate_command(cmd_str):
            cmd_str = cmd_str.strip()
            if not cmd_str:
                return "ask"

            if "\n" in cmd_str or "\r" in cmd_str:
                return "ask"

            substitutions = extract_substitutions(cmd_str)
            for kind, _, inner, _ in substitutions:
                if kind in ("cmd", "proc"):
                    inner_decision = evaluate_command(inner)
                    if inner_decision == "deny":
                        return "deny"
                    if inner_decision != "allow":
                        return "ask"
                elif kind == "arith":
                    if not re.match(r"^[\d\s+\-*/%()]+$", inner):
                        return "ask"

            normalized_cmd = cmd_str
            for _, full_expr, _, _ in substitutions:
                normalized_cmd = normalized_cmd.replace(full_expr, "__ARG__")

            try:
                lexer = shlex.shlex(normalized_cmd, posix=True, punctuation_chars="|;&><")
                lexer.whitespace_split = False
                tokens = list(lexer)
            except Exception:
                return "ask"

            if not tokens:
                return "ask"

            operators = {"|", ";", "&&", "||", ">", ">>", "<", "&"}
            segments = []
            current = []
            has_non_pipe_operator = False

            for tok in tokens:
                if tok in operators:
                    if tok != "|":
                        has_non_pipe_operator = True
                    elif not current:
                        return "ask"
                    if current:
                        segments.append(" ".join(current).strip())
                        current = []
                else:
                    current.append(tok)

            if current:
                segments.append(" ".join(current).strip())
            elif "|" in tokens:
                return "ask"

            for seg in segments:
                cleaned = clean_segment(seg)
                if any(matches_rule(cleaned, target) for target in DENIED_COMMANDS):
                    return "deny"

            if has_non_pipe_operator or not segments:
                return "ask"

            if all(
                any(matches_rule(clean_segment(seg), target) for target in ALLOWED_COMMANDS)
                for seg in segments
            ):
                return "allow"

            return "ask"


        def resolve_command(cmd_str):
            substitutions = extract_substitutions(cmd_str)
            if not substitutions:
                return cmd_str

            resolved = cmd_str
            for kind, full_expr, inner, in_double in substitutions:
                if kind == "arith":
                    try:
                        if re.match(r"^[\d\s+\-*/%()]+$", inner):
                            val = str(eval(inner, {"__builtins__": None}, {}))
                            resolved = resolved.replace(full_expr, val, 1)
                    except Exception:
                        pass
                elif kind in ("cmd", "proc"):
                    resolved_inner = resolve_command(inner)
                    try:
                        proc = subprocess.run(
                            resolved_inner,
                            shell=True,
                            executable=shutil.which("bash") or "/bin/sh",
                            capture_output=True,
                            text=True,
                            timeout=5,
                        )
                        out = proc.stdout.strip()
                        if in_double:
                            val = out.replace("\\", "\\\\").replace('"', '\\"')
                        else:
                            words = out.split()
                            val = " ".join(shlex.quote(w) for w in words)
                        resolved = resolved.replace(full_expr, val, 1)
                    except Exception:
                        pass
            return resolved


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

            tool_call = data.get("toolCall") or data.get("tool_call") or {}
            tool_name = (
                tool_call.get("name") or tool_call.get("tool_name") or ""
            ).lower()
            if tool_name not in ("run_command", "runcommand"):
                print(json.dumps({"decision": "ask"}))
                return

            args = tool_call.get("args") or tool_call.get("arguments") or {}
            cmd_line = (
                args.get("CommandLine")
                or args.get("command_line")
                or args.get("command")
                or ""
            ).strip()
            if not cmd_line:
                print(json.dumps({"decision": "ask"}))
                return

            decision = evaluate_command(cmd_line)
            if decision != "allow":
                if decision == "deny":
                    print(
                        json.dumps({
                            "decision": "deny",
                            "reason": "Command matches denyRules",
                        })
                    )
                else:
                    print(json.dumps({"decision": "ask"}))
                return

            substitutions = extract_substitutions(cmd_line)
            if substitutions:
                resolved_cmd = resolve_command(cmd_line)
                if resolved_cmd != cmd_line and evaluate_command(resolved_cmd) == "allow":
                    print(
                        json.dumps({
                            "decision": "allow",
                            "reason": "Approved command substitution from allowRules",
                            "permissionOverrides": [f"command({cmd_line})"],
                            "overwrite": {
                                "CommandLine": resolved_cmd,
                            },
                        })
                    )
                    return

            print(
                json.dumps({
                    "decision": "allow",
                    "reason": "Approved command/pipeline from allowRules",
                })
            )


        if __name__ == "__main__":
            main()
      '';
in
{
  programs.antigravity-cli = {
    enable = true;

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
      model = "Gemini 3.8 Flash (High)";
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
      - Command Execution & Pipelines: Pipelines and command substitutions composed exclusively of read-only inspection utilities (e.g. `git`, `grep`, `awk`, `sed`, `jq`, `head`, `tail`, `sort`, `uniq`, `wc`, `cat`, `cut`, `tr`, `find`, `fd`, `strings`, `which`, `nm`) are permitted and auto-approved via the pipeline PreToolUse hook. Do not chain mutating commands with `&&`, `||`, `;`, or shell redirection in `run_command`.
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
