---
title: Code Quality & Evaluation
description: Formatting, linting, flake evaluation, and conventional commit standards.
---

This guide outlines code formatting, linting, evaluation, and git conventions enforced across the `nix-config` repository.

---

## 1. Unified Formatting via `treefmt`

The repository uses [`treefmt-nix`](https://github.com/numtide/treefmt-nix) to provide unified, multi-language formatting and linting under a single command:

```bash
nix fmt
```

### Supported Languages & Formatters (`treefmt/`):
- **Nix**: Formatted using `nixfmt-rfc-style`.
- **Bash / Shell scripts**: Linted and formatted via `shellcheck` and `shfmt`.
- **Lua**: Formatted using `stylua`.
- **TOML**: Formatted using `taplo`.

> [!NOTE]
> Auto-generated `hardware-configuration.nix` files are exempt from manual edits. Formatters and linters automatically skip or ignore auto-generated hardware configurations.

---

## 2. Flake Evaluation

Verify that all flake outputs evaluate cleanly without errors:

```bash
nix flake check
```

This verifies the integrity of all NixOS system closures, Home Manager configurations, and checks defined in the flake.

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

| Repository Type | Formatting Behavior | Outcome |
| :--- | :--- | :--- |
| **Flakes with a configured `formatter`** | Runs `nix fmt` from root, displays summary | Formats and commits if clean; aborts on syntax error |
| **Flakes without a `formatter`** | Catches missing attribute error | Silently skips formatting without errors and commits |
| **Non-Flake Repositories** | Bypasses `nix fmt` step entirely | Immediately stages, commits, and pushes |

### Commit Message Conventions
Commit messages must strictly follow the **Conventional Commits** specification with a single-line format:

```text
<type>(<scope>): <short description>
```

#### Common Types:
- `feat`: A new host, module, application, or functional feature (e.g. `feat(hosts/mini-pc-k8): add harmonia cache`).
- `fix`: Bug fix or hardware quirk correction (e.g. `fix(audio): restrict ALSA card profile to physical jacks`).
- `docs`: Documentation updates or wiki enhancements (e.g. `docs(k8): document UEFI shell flashing steps`).
- `chore`: Maintenance, key rotations, or dependencies (e.g. `chore(secrets): rekey secrets for new host`).
- `refactor`: Code reorganization without functional changes.

---

## 4. Continuous Integration & Lockfile Policy

- **`flake.lock` Management:** The `flake.lock` file is managed strictly by automated CI schedules (`update-flake-mr`). Do not update or modify lockfiles locally unless you updated `flake.nix`.
- **Automated MR Superseding & Gate Optimization:** When `update-flake-mr` runs, it gates update cycles on `nixpkgs`—updating `nixpkgs` first and short-circuiting immediately if no upstream changes exist. If `nixpkgs` has advanced, it updates the remaining inputs, automatically closes any older unmerged `dependencies` merge requests, and deletes their remote branches before creating the fresh update. Full system closure build verification, automated merges, and MR failure reporting (`build-error` label + build log comment) are handled safely by `flake-update-verifier` on the local desktop workstation.
- **Pre-merge Verification:** Automated CI pipelines test flake evaluation, formatting, and linting on all merge requests before they can be merged into `main`.
- **Dual-Forge Architecture:** Fleet evaluations and automated maintenance bots run natively on GitLab CI, while GitHub Actions is restricted strictly to documentation deployments. See [Split CI Architecture](/split-ci/) for the complete rationale and operational model.
