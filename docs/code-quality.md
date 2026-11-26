---
title: Code Quality & Evaluation
description: Formatting, linting, flake evaluation, and conventional commit standards.
---

This guide outlines code formatting, linting, evaluation, and git conventions enforced across the `nix-config` repository.

---

## 1. Unified Formatting via `treefmt`

The repository uses [`treefmt-nix`](https://github.com/numtide/treefmt-nix) to provide unified, multi-language formatting and linting under a single command:

```bash
just format
```

### Supported Languages & Formatters (`treefmt/`):

- **Nix**: Linted and formatted using `deadnix`, `statix`, and `nixfmt`.
- **Bash / Shell scripts**: Linted and formatted via `shellcheck` and `shfmt`.
- **C / C++**: Formatted using `clang-format`.
- **Just**: Formatted using `just --fmt`.
- **Lua**: Formatted using `stylua`.
- **Markdown**: Formatted using `prettier` (`*.md`).
- **TOML**: Formatted using `toml-sort`.

> [!NOTE]
> Auto-generated `hardware-configuration.nix` files are exempt from manual edits. Formatters and linters automatically skip or ignore auto-generated hardware configurations.

---

## 2. Flake Evaluation

Verify formatting and that all flake outputs evaluate cleanly without errors:

```bash
just check
```

This runs `nix fmt -- --fail-on-change` and `nix flake check --no-build`, verifying formatting as well as the integrity of all NixOS system closures, Home Manager configurations, and flake outputs.

---

## 3. Git Workflow & Conventional Commits

### Commit Workflow

The repository provides a streamlined git alias, `git lazy`, which formats code, stages changes, creates a commit, and pushes to upstream:

```bash
git lazy "<commit message>"
```

#### Under the Hood

The alias executes an inline shell function designed to balance automated code formatting with safety across heterogeneous Git repositories:

```bash
f() {
  # 1. Resolve repository root (supports invocation from any subdirectory)
  top="$(git rev-parse --show-toplevel 2>/dev/null)"

  # 2. Check for flake-based configuration
  if [ -f "$top/flake.nix" ]; then
    out="$( (cd "$top" && nix fmt) 2>&1 )"
    res=$?

    if [ $res -ne 0 ]; then
      case "$out" in
        # Suppress errors if the flake does not provide a formatter (e.g. treefmt-nix is not set up)
        *"does not provide attribute"*"formatter"*) ;;
        # Abort if formatting failed due to genuine syntax or evaluation errors
        *) echo "$out" >&2; return 1 ;;
      esac
    elif [ -n "$out" ]; then
      # Print formatter summary if successful
      echo "$out"
    fi
  fi

  # 3. Stage all modifications, commit with message, and push upstream
  git add -A && git commit -m "$1" && git push
}
```

#### Behavior Across Repository Types

| Repository Type                          | Formatting Behavior                        | Outcome                                              |
| :--------------------------------------- | :----------------------------------------- | :--------------------------------------------------- |
| **Flakes with a configured `formatter`** | Runs `nix fmt` from root, displays summary | Formats and commits if clean; aborts on syntax error |
| **Flakes without a `formatter`**         | Catches missing attribute error            | Silently skips formatting without errors and commits |
| **Non-Flake Repositories**               | Bypasses `nix fmt` step entirely           | Immediately stages, commits, and pushes              |

### Commit Message Conventions

Commit messages must strictly follow the **Conventional Commits** specification with a single-line format:

```text
<type>(<scope>): <short description>
```

#### Common Types:

- `feat`: A new host, module, application, or functional feature (e.g. `feat(hosts/mini-pc-k8): add network share`).
- `fix`: Bug fix or hardware quirk correction (e.g. `fix(audio): restrict ALSA card profile to physical jacks`).
- `docs`: Documentation updates or wiki enhancements (e.g. `docs(k8): document UEFI shell flashing steps`).
- `chore`: Maintenance, key rotations, or dependencies (e.g. `chore(secrets): rekey secrets for new host`).
- `refactor`: Code reorganization without functional changes.

---

## 4. Continuous Integration & Lockfile Policy

- **`flake.lock` Management:** The `flake.lock` file is managed strictly by automated CI schedules (`update-flake-mr` and `update-flake-weekly-mr`). Do not update or modify lockfiles locally unless you updated `flake.nix`.
- **Minimal CI Container Discipline:** CI maintenance jobs using `nixos/nix:latest` operate in a minimal base container without utilities like `awk` or standalone `jq`. All scripted maintenance logic must rely strictly on POSIX `sh` builtins, file redirection rather than piped subshells (ensuring `exit 0` short-circuiting terminates the primary script), and declarative `nix eval` expressions for JSON parsing.
- **Automated MR Superseding & Gate Optimization:** Automated flake updates are split across two scheduled jobs sharing `.update-flake-base`:
  - `update-flake-mr` (`RUN_FLAKE_UPDATE=true`): Gates update cycles on `nixpkgs`—updating `nixpkgs` first and short-circuiting immediately if no upstream changes exist relative to `main`, or if an existing open `flake-update-*` branch already contains the same `nixpkgs` revision.
  - `update-flake-weekly-mr` (`RUN_WEEKLY_FLAKE_UPDATE=true`): Designed for a dedicated Sunday schedule, bypassing the `nixpkgs` gate to update all public inputs even during pre-release `nixpkgs` freezes. It short-circuits if no public inputs changed or if an open `flake-update-*` branch already matches the full public `flake.lock` state.
    When either job produces a new update, it automatically closes any older unmerged `dependencies` merge requests and deletes their remote branches before creating the fresh update. Automatic rebasing onto `main`, full system closure build verification, deduplicated common and per-device `dix` package diff summaries in the MR description, automated merges, and MR failure reporting (`build-error` label + build log comment) are handled safely by `flake-update-verifier` on the local desktop workstation (or on demand via the `nverify` shell alias).
- **Pre-merge Verification:** Automated CI pipelines test flake evaluation, formatting, and linting on all merge requests before they can be merged into `main`.
- **Dual-Forge Architecture:** Fleet evaluations and automated maintenance bots run natively on GitLab CI, while GitHub Actions is restricted to non-critical installer ISO builds and documentation deployments. See [Split CI Architecture](/nix-config/split-ci/) for the complete rationale and operational model.
