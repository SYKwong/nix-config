# Repository Guidelines

## NixOS & Repository Conventions
- Dependencies: `flake.lock` is managed strictly by CI; do not update or modify locks locally unless `flake.nix` was modified.
- Formatting: Format code with `nix fmt`. It currently supports bash/sh, lua, nix, and toml.
- Hardware files: Never edit auto-generated `hardware-configuration.nix` files.
- Portability & Modularity: Avoid hardcoded numeric UIDs/GIDs (prefer dynamic `username` and `users` group). Keep host-specific logic in `hosts/<name>/` and reusable features in `modules/<category>/`.
- Hyprland Lua Conventions: Use standard `function table.name()` syntax instead of anonymous assignments (`table.name = function()`). Keybinding action helpers in `utils.lua` should return callback closures rather than raw command strings.
- Desktop Shell: The environment uses Noctalia; legacy Waybar/sway-specific tools and derivations should be pruned when encountered.
- Nix Store Access: Never attempt direct filesystem reads, searches, or traversals on `/nix/store` (these are hard-locked and will block execution). Always inspect configuration options, module definitions, and package metadata declaratively via `nix eval` (e.g., `nix eval .#nixosConfigurations.<host>.options.<option>` or `nix eval .#nixosConfigurations.<host>.config.<path>`). Only if declarative evaluation fails or raw source inspection is strictly unavoidable should you trigger a store read request, providing the exact path and rationale.

## Git & Workflow
- Branching: If currently on `main`, automatically create and switch to a new branch for the task without asking for permission. If on another branch, ask the user whether to branch from the current branch or from `main`.

## Provisioning & Installation Scripts (install.sh, post-install.sh)
- Hands-off by Default: Host onboarding and setup scripts must run unattended/non-interactively by default. Interactive setup steps (e.g. service logins) must be opt-in behind flags (e.g. `--auth`).
- Intent & Prompts: When an explicit setup flag is passed, proceed directly without redundant per-service confirmation prompts (`[Y/n]`), using non-interactive CLI flags where available (e.g., `glab auth login --web`).
- No Redundant PATH Checks: Avoid defensive `command -v` checks in onboarding scripts for tools declaratively managed via NixOS / Home Manager.

## Documentation Site
- Documentation is maintained in-tree under `docs/` using Astro Starlight and deployed to `nix.kyle-kwong.com`.
- When adding or updating features, keep documentation in `docs/src/content/docs/` synchronized with the implementation.
- Only run `npx --no-install astro build` in `docs/` when adding, removing, or renaming documentation pages, or when modifying `docs/astro.config.mjs`, `docs/package.json`, or `docs/src/styles/` (skip the build for routine content edits to existing `.md` files). If `docs/node_modules/` is missing when a build is required, initialize it via `npm ci --ignore-scripts` in `docs/`.
- Maintain Catppuccin theme conventions and upright code typography.
