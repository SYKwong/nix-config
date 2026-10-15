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
The repository provides a streamlined git alias, `git lazy`, which automatically runs `nix fmt` (if `flake.nix` is present), stages all changes, creates a commit, and pushes to upstream:

```bash
git lazy "<commit message>"
```

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
- **Pre-merge Verification:** Automated CI pipelines test flake evaluation, formatting, and linting on all merge requests before they can be merged into `main`.
