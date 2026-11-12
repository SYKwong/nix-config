{ pkgs, username, ... }:

let
  projectRepos = [
    "dev-notes"
    "nixos-hardware"
    "noctalia"
  ];

  trustedDirectories = [
    "/home/${username}/nix-config"
    "/home/${username}/nix-config/"
    "~/nix-config"
    "~/nix-config/"
  ]
  ++ builtins.concatMap (repo: [
    "/home/${username}/Projects/${repo}"
    "/home/${username}/Projects/${repo}/"
    "~/Projects/${repo}"
    "~/Projects/${repo}/"
  ]) projectRepos;

  gitSubcommands = [
    "-c core.hooksPath=/dev/null -c core.fsmonitor=false pull --ff-only origin dev"
    "-c core.hooksPath=/dev/null -c core.fsmonitor=false pull --ff-only origin develop"
    "-c core.hooksPath=/dev/null -c core.fsmonitor=false pull --ff-only origin main"
    "-c core.hooksPath=/dev/null -c core.fsmonitor=false pull --ff-only origin master"
    "add"
    "branch"
    "checkout"
    "describe"
    "diff"
    "fetch"
    "grep"
    "log"
    "ls-files"
    "ls-remote"
    "ls-tree"
    "merge-base"
    "remote"
    "rev-parse"
    "rm"
    "shortlog"
    "show"
    "stash apply"
    "stash list"
    "stash pop"
    "stash push"
    "stash show"
    "status"
    "switch"
    "tag"
  ];

  baseGitRules = map (subcmd: "command(git ${subcmd})") gitSubcommands;

  gitDirRules = builtins.concatMap (
    dir: map (subcmd: "command(git -C ${dir} ${subcmd})") gitSubcommands
  ) trustedDirectories;

  allowRules =
    baseGitRules
    ++ gitDirRules
    ++ [
      # GitHub Operations
      "command(gh issue list)"
      "command(gh issue status)"
      "command(gh issue view)"
      "command(gh pr checks)"
      "command(gh pr diff)"
      "command(gh pr list)"
      "command(gh pr status)"
      "command(gh pr view)"
      "command(gh release list)"
      "command(gh release view)"
      "command(gh repo view)"
      "command(gh run list)"
      "command(gh run view)"
      "command(gh run watch)"
      "command(gh search code)"
      "command(gh search issues)"
      "command(gh search prs)"
      "command(gh status)"

      # GitLab Operations
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
      "command(nix develop)"
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
      "command(safe-npm)"
      "command(safe-npx)"
      "command(safe-python)"

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
      "command(systemctl --user is-active)"
      "command(systemctl --user status)"
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

  allowedCommands = builtins.filter (cmd: cmd != "nix develop") (extractCommands allowRules);
  deniedCommands = extractCommands denyRules;

  devAllowedCommands = [
    "clang-format"
    "clang-tidy"
    "just"
    "meson"
    "ninja"
    "node"
    "pkg-config"
    "run-clang-tidy"
  ];

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
        DEV_ALLOWED_COMMANDS = json.loads(
            r"""${builtins.toJSON devAllowedCommands}"""
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


        def extract_nix_develop_inner(cmd_str):
            try:
                lexer = shlex.shlex(cmd_str, posix=True, punctuation_chars="|;&><")
                lexer.whitespace_split = False
                lexer.commenters = ""
                tokens = list(lexer)
            except Exception:
                return None

            if tokens and tokens[0] == "nix" and "develop" in tokens:
                dev_idx = tokens.index("develop")
                for i, tok in enumerate(tokens[dev_idx + 1:], start=dev_idx + 1):
                    if tok in ("-c", "--command"):
                        remaining = tokens[i + 1:]
                        if not remaining:
                            return None
                        inner = " ".join(remaining)
                        try:
                            sub_lexer = shlex.shlex(
                                inner, posix=True, punctuation_chars="|;&><"
                            )
                            sub_lexer.whitespace_split = False
                            sub_lexer.commenters = ""
                            sub_tokens = list(sub_lexer)
                            if (
                                len(sub_tokens) >= 3
                                and sub_tokens[0] in ("bash", "sh")
                                and sub_tokens[1] == "-c"
                            ):
                                return " ".join(sub_tokens[2:])
                        except Exception:
                            pass
                        return inner
            return None


        def evaluate_dev_inner(inner_str):
            try:
                inner_lexer = shlex.shlex(
                    inner_str, posix=True, punctuation_chars="|;&><"
                )
                inner_lexer.whitespace_split = False
                inner_lexer.commenters = ""
                inner_tokens = list(inner_lexer)
            except Exception:
                return "ask"

            segments = []
            cur = []
            has_redirection = False
            for tok in inner_tokens:
                if tok in (">", ">>", "<"):
                    has_redirection = True
                if tok in (";", "&&", "||", "|"):
                    if cur:
                        segments.append(" ".join(cur).strip())
                        cur = []
                else:
                    cur.append(tok)
            if cur:
                segments.append(" ".join(cur).strip())

            for seg in segments:
                cleaned = clean_segment(seg)
                if any(matches_rule(cleaned, target) for target in DENIED_COMMANDS):
                    return "deny"

            if has_redirection or not segments:
                return "ask"

            for seg in segments:
                cleaned = clean_segment(seg)
                allowed = (
                    any(matches_rule(cleaned, target) for target in ALLOWED_COMMANDS)
                    or any(matches_rule(cleaned, target) for target in DEV_ALLOWED_COMMANDS)
                    or bool(re.match(r"^(\./)?build[a-zA-Z0-9_-]*/[a-zA-Z0-9_-]+(\s|$)", cleaned))
                )
                if not allowed:
                    return "ask"

            return "allow"


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
                lexer.commenters = ""
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

            def is_nix_develop(cmd_str):
                cleaned_cmd = clean_segment(cmd_str)
                if cleaned_cmd == "nix develop" or cleaned_cmd.startswith("nix develop "):
                    return True
                try:
                    lx = shlex.shlex(cmd_str, posix=True, punctuation_chars="|;&><")
                    lx.whitespace_split = False
                    lx.commenters = ""
                    t = list(lx)
                    return bool(t and t[0] == "nix" and "develop" in t)
                except Exception:
                    return False

            def evaluate_single_segment(seg):
                cleaned = clean_segment(seg)
                if is_nix_develop(seg):
                    inner = extract_nix_develop_inner(seg)
                    if inner is not None:
                        return evaluate_dev_inner(inner)
                    return "ask"
                if any(matches_rule(cleaned, target) for target in ALLOWED_COMMANDS):
                    return "allow"
                return "ask"

            decisions = [evaluate_single_segment(seg) for seg in segments]
            if "deny" in decisions:
                return "deny"
            if all(d == "allow" for d in decisions):
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
                    "permissionOverrides": [f"command({cmd_line})"],
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
      ]
      ++ map (repo: "/home/${username}/Projects/${repo}") projectRepos;
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
      - Self-Documenting Code Over Comments: Do not add inline comments to explain production code blocks if the logic can be extracted into a self-describing helper or wrapper function (placed immediately preceding the caller). Only use comments when the intent or constraint cannot be expressed through naming. Never remove pre-existing comments written by other authors unless explicitly instructed. In test code, comments explaining scenarios, state transitions, or edge-case expectations are welcomed whenever function names cannot easily describe them.
      - Code Locality, Constants & Helpers: Avoid hoisting constants or helper functions to distant file headers. Assign magic numbers to named constant variables declared as late and locally as possible. Place private helper functions physically as close as possible to the consumers that use them (e.g. immediately preceding the calling function) to preserve local reading context.
      - Minimal Diff Churn: Do not reorder, move, or refactor unrelated functions or code blocks unless explicitly requested or necessary for functionality.
      - Guard Clauses & Early Returns: Prefer early returns / guard clauses over deep nesting or trailing else blocks to keep execution flow flat.
      - Variable Naming: Prefer clear, descriptive, and verbose variable names over terse abbreviations (e.g. `logical_monitor_width` instead of `mon_w`).

      ## Command & File Operations
      - Command Execution & Pipelines: Pipelines and command substitutions composed exclusively of read-only inspection utilities (e.g. `git`, `grep`, `awk`, `sed`, `jq`, `head`, `tail`, `sort`, `uniq`, `wc`, `cat`, `cut`, `tr`, `find`, `fd`, `strings`, `which`, `nm`, `safe-python`) are permitted and auto-approved via the pipeline PreToolUse hook. Do not chain mutating commands with `&&`, `||`, `;`, or shell redirection in `run_command`.
      - Sandboxed Execution & Testing: Always prioritize sandboxed runners (`safe-python`, `safe-npm`, `safe-npx`) over un-sandboxed equivalents (`python3`, `npm`, `npx`) for tests, evaluations, dry-runs, builds, and package operations to protect against supply-chain attacks. Raw commands require interactive user approval.
      - File Creation and Modification: Always use `write_to_file` or `replace_file_content` to create or edit files in the workspace. Never use `cat << 'EOF' > ...` or shell redirection in `run_command`, as shell redirection triggers CLI permission prompts.
      - Nix Store Operations: Never attempt direct filesystem reads, searches, or traversals on `/nix/store` (these are hard-locked and will block execution). Always inspect configuration options, module definitions, and package metadata declaratively via `nix eval` (e.g., `nix eval .#nixosConfigurations.<host>.options.<option>` or `nix eval .#nixosConfigurations.<host>.config.<path>`). Only if declarative evaluation fails or raw source inspection is strictly unavoidable should you trigger a store read request, providing the exact path and rationale.

      ## Documentation & Markdown
      - Mandatory Documentation Synchronization: Whenever modifying code, scripts, or configurations, always proactively identify and update all related documentation and markdown files (such as project wikis, module/directory READMEs, architecture specs, and topic guides) before concluding the task. Never leave documentation updates for a follow-up prompt unless clarification is needed.

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

      ## Project Memory & Cross-Machine Knowledge
      - In-Tree Memory: For internal projects that support it, maintain persistent notes in `.agents/memory.md` or `AGENTS.md`.
      - External Projects: For external, upstream, or client repositories where `.agents/` is not viable:
        - Maintain notes in `~/Projects/dev-notes/projects/<repo-name>.md`.
        - Never create or commit `.agents/` or memory files in the external repo's working tree.
      - Recording Knowledge: When resolving a non-trivial bug, establishing an architecture pattern, or discovering a persistent preference:
        1. Propose the concise takeaway to the user before concluding the task.
        2. With user approval, save it to the appropriate memory file.
        3. Notes in `~/Projects/dev-notes` automatically sync across all your machines on session start and finish.
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

    dev-notes-sync = {
      SessionStart = [
        {
          type = "command";
          command = "[ -d ~/Projects/dev-notes/.git ] && GIT_SSH_COMMAND=\"ssh -o BatchMode=yes -o ConnectTimeout=3\" git -C ~/Projects/dev-notes pull --rebase --autostash -q 2>/dev/null || true; echo '{}'";
          timeout = 6;
        }
      ];
      Stop = [
        {
          type = "command";
          command = "[ -d ~/Projects/dev-notes/.git ] && [ -n \"$(git -C ~/Projects/dev-notes status --porcelain 2>/dev/null)\" ] && git -C ~/Projects/dev-notes add -A && git -C ~/Projects/dev-notes commit -m 'sync(notes): automated update' -q && GIT_SSH_COMMAND=\"ssh -o BatchMode=yes -o ConnectTimeout=3\" git -C ~/Projects/dev-notes push -q 2>/dev/null || true; echo '{}'";
          timeout = 6;
        }
      ];
    };
  };
}
