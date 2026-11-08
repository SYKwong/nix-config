---
title: Home Manager User Configuration
description: Declarative user-space environment, Noctalia desktop shell, live dotfiles, and application suites.
---

This directory contains declarative user-space configurations managed by [Home Manager](https://github.com/nix-community/home-manager). Everything defined here operates strictly within the user environment (`programs.*`, `home.*`, `xdg.*`) and is imported across all hosts via `modules/home-manager/default.nix`.

---

## Directory Taxonomy

| Category | Path | Description |
| :--- | :--- | :--- |
| **`core/`** | `home/core/` | Baseline user environment (`xdg.userDirs`, default folder structures). |
| **`cli/`** | `home/cli/` | Terminal utilities (`atuin`, `bat`, `btop`, `eza`, `fastfetch`, `fzf`, `git`, `yazi`, `zoxide`, `antigravity`). |
| **`desktop/`** | `home/desktop/` | Noctalia desktop shell (status bar, OSD, lockscreen, runner, idle management). |
| **`browsers/`** | `home/browsers/` | Web browsers (Zen Browser, Helium). |
| **`editors/`** | `home/editors/` | Text editors, primarily NixVim (declarative Neovim) and Zed. |
| **`media/`** | `home/media/` | Media players and desktop streaming (`feishin`, `mpv`, `jellyfin-desktop`). |
| **`shell/`** | `home/shell/` | Fish shell configuration, interactive prompts, completions, and aliases (`alias.nix`). |
| **`social/`** | `home/social/` | Messaging and social clients (`vesktop`). |
| **`theme/`** | `home/theme/` | GTK theme settings and Stylix user-level overrides. |
| **`misc/`** | `home/misc/` | System glue: out-of-store dotfile symlinking (`dotfile.nix`), and custom/hidden desktop entries. |

---

## Key Conventions

### 1. User Scope Purity
Modules in `home/` operate strictly within user space. Packages are declared via `home.packages` (or program-specific `programs.<name>.enable` options), and user-level background daemons are managed via Home Manager's own `services.*` options or user systemd units (`systemd.user.services`). System-wide configuration (such as hardware drivers, kernel parameters, and root-level system services) belongs in `modules/`.

### 2. Live Out-of-Store Dotfiles
Fast-iterating configuration files (Hyprland Lua scripts, Kitty, and Foot configurations) are not baked into the read-only Nix store. Instead, they reside in `config/` and are symlinked directly via `config.lib.file.mkOutOfStoreSymlink` in `home/misc/dotfile.nix`. See the [Out-of-Store Dotfiles](/dotfiles/) guide for details.

### 3. Desktop Entries & Application Hiding
Custom `.desktop` launchers and hiding rules for unwanted third-party app shortcuts are managed in `home/misc/`. See the [Managing Desktop Entries](/desktop-entries/) guide.

### 4. Host-Specific User Extensions
Common configurations are shared by all machines. If a machine requires unique user packages or settings, place them in `hosts/<hostname>/home/default.nix`, which is automatically discovered and imported.

### 5. Declarative Application State Merging
For applications that persist local JSON/INI configurations directly in mutable profile paths (such as Helium Browser's Chromium preferences), configuration values are declared as Nix attribute sets, rendered via `pkgs.writeText`, and merged into `$HOME` during Home Manager activation hooks (`home.activation.<name>`) using `jq` deep-merging to prevent user profile state erasure.

### 6. Category-Scoped Media Playlists
Desktop media players are segmented by workload:
- **`feishin`**: Navidrome / Subsonic music streaming client with out-of-store configuration.
- **`mpv`**: General media player configured with `autocreate-playlist = "same"` (enqueuing neighboring tracks) and `vo = "gpu-next"` with `target-colorspace-hint-mode = "source"` for automated HDR handoff under Hyprland's `cm_auto_hdr`. Compositor blur and transparency are eliminated via Hyprland window rules (`force_rgbx = true` and `opaque = true`).
- **`jellyfin-desktop`**: TV and movie streaming from local Jellyfin media servers.

### 7. Shell History & Smart Suggestions (`atuin` + `atuin-to-fish`)
Shell history is synchronized across devices headlessly via Atuin (`home/cli/atuin.nix`):
- **Headless Sync**: Atuin operates purely as a background synchronization engine without intercepting terminal keybindings (`Ctrl+R` and Up-arrow remain native to FZF and Fish).
- **Declarative Authentication**: Atuin automatically authenticates across the fleet using credentials stored in `secrets/atuin-credentials.age` via `atuin-auto-login` (integrated into systemd user services, `rebuild`, and `atuin-to-fish`), eliminating interactive login prompts. See [Atuin Shell History Sync Setup](/secrets/#4-atuin-shell-history-sync-setup-atuin-credentialsage) for instructions on registering or obtaining your 24-word encryption key.
- **Autosuggestion Bridging**: Fish's inline ghost-text autosuggestions query local Fish history. To keep suggestions populated with synced commands across machines, `atuin-to-fish` runs automatically at the start of `rebuild` (`nrs`), extracting newly synced commands from Atuin and merging them into Fish history.
- **Live Prompt Sync**: `fish/conf.d/history-merge.fish` merges newly written commands on prompt, ensuring open sessions immediately reflect incoming suggestions.

### 8. Declarative Zen Browser Pins & Essentials (`home/browsers/zen.nix`)
Zen Browser workspaces, pinned tabs, and global essentials are managed declaratively via `programs.zen-browser.profiles.<name>.pins` through `inputs.zen-browser.homeModules.beta`:
- **Pin Identification (`id`)**: Every pin requires a unique RFC 4122 Version 4 UUID string. Generate a fresh ID via the standard CLI command `uuidgen`:
  ```bash
  uuidgen
  # Output: ddcbb895-1e7d-4e6c-9192-16c72361028a
  ```
  Zen Browser injects this string as `zenSyncId` (`"{<uuid>}"`) inside `zen-sessions.jsonlz4`. It acts as the tab's immutable primary key to track identity across window lifecycles, workspace switches, and nested folder structures (`folderParentId`).
- **Session Reconciliation (`pinsForce`)**: When `pinsForce = true` and `pinsForceAction = "remove"`, Home Manager compares existing session tabs against declared pins during activation. Undeclared pinned tabs are pruned from the session, while declared pins have their URLs, labels, and ordering (`position`) reconciled without duplicating tabs.
- **Global Essentials (`isEssential = true`)**: Pins with `isEssential = true` are pinned globally across all Zen workspaces (displayed at the top of the sidebar or in SuperPins grids). Pins without this flag are workspace-scoped.

### 9. Antigravity Agent Memory & Just-in-Time Sync (`home/cli/antigravity.nix`)
Antigravity CLI (`agy`) persistent memory and cross-machine knowledge synchronization is managed through two complementary mechanisms:
- **In-Tree Memory (`.agents/memory.md` / `AGENTS.md`)**: Used for repositories that accept in-tree agent memory and documentation. Memories are committed and travel natively alongside codebase changes via Git.
- **Out-of-Tree Dev Notes (`~/Projects/dev-notes`)**: For external, upstream, or client repositories where adding `.agents/` or `AGENTS.md` is forbidden or would pollute upstream pull requests.

#### Setting Up the Private `dev-notes` Repository
To initialize cross-machine agent memory across your fleet:

1. **Create a Private Repository**: Create a private repository named `dev-notes` on GitLab (or GitHub).
2. **Clone to Workstations**:
   ```bash
   git clone git@gitlab.com:<your-username>/dev-notes.git ~/Projects/dev-notes
   ```
3. **Scaffold Directory Structure**:
   ```bash
   mkdir -p ~/Projects/dev-notes/projects
   touch ~/Projects/dev-notes/global.md
   ```
   - **`global.md`**: Cross-project user preferences, common hardware quirks, and fleet conventions.
   - **`projects/<repo-name>.md`**: Per-project learnings, API keys/environment notes, and architecture workarounds for external codebases (e.g. `nixpkgs.md`, `linux-kernel.md`).

#### Just-in-Time Lifecycle Hooks
Instead of continuous background daemons, synchronization is automated just-in-time via `home/cli/antigravity.nix`:
- **`SessionStart`**: Automatically runs `git pull --rebase --autostash -q` in `~/Projects/dev-notes` before your first prompt.
- **`Stop`**: Automatically checks for unstaged notes changes upon conversation completion, commits them, and pushes to remote.
- **Offline Resilient**: Uses SSH guards (`BatchMode=yes`, `ConnectTimeout=3`). If working offline (or before `dev-notes` is cloned), the hooks safely bypass in milliseconds without blocking prompt execution.

#### Pre-Approved Git Workspaces
To streamline multi-repo workflows without interactive permission prompts, `home/cli/antigravity.nix` automatically approves safe read and staging Git subcommands (e.g., `status`, `diff`, `log`, `branch`, `checkout`, `switch`, `fetch`, `add`, `rm`) scoped via `git -C <dir>` across trusted workspaces (`~/nix-config` and `~/Projects/<repo>`). Mutating operations (`commit`, `push`, `reset`, `restore`) remain strictly guarded.

#### Pre-Approved Build Tools in Development Shells
To avoid host toolchain pollution and ensure reproducible builds, native build tools are not installed globally on the host PATH. Instead, the Antigravity `pipelineAllowHook` automatically unwraps and approves `nix develop -c <cmd>` and `nix develop --command bash -c "<cmd>"` invocations when inner commands are approved development tools:
- **Approved Dev Tools**: `just`, `ninja`, `meson`, `clang-format`, `clang-tidy`, `pkg-config`, `run-clang-tidy`, and local build artifacts matching `./build*/*`.
- **Host Protection**: Running build tools directly on the host (outside `nix develop`) prompts for interactive confirmation.
- **Dangerous Commands Guarded**: Any destructive command (`sudo`, `rm`, shell redirections, or unvetted utilities) returns a hook denial or prompts for permission, even when wrapped within `nix develop`.
- **Desktop Shell Inspection**: User systemd queries (`systemctl --user status` and `systemctl --user is-active`) are pre-approved to facilitate inspecting user services like `noctalia`.

---

## Noctalia Idle Management

Idle timeouts and power states are managed natively by Noctalia (`home/desktop/noctalia.nix`) using the Wayland `ext_idle_notifier_v1` protocol, consolidating idle handling without requiring external daemons like `hypridle`.

### Desktop Scaling Multiplier (`idle_scale`)
To accommodate living-room HTPC and desktop workstation environments where aggressive power saving is disruptive, `home/desktop/noctalia.nix` dynamically adjusts idle intervals based on host type:
- **Laptops (`framework16`):** Uses baseline timeouts (`idle_scale = 1`).
- **Desktops / HTPCs (`mini-pc-k8`):** Applies a 3x multiplier (`idle_scale = 3`) when `is_desktop = true`.

### Timeline & Behaviors

| Laptop (1x) | Desktop (3x) | Target / Action | Behavior Name | Description |
| :--- | :--- | :--- | :--- | :--- |
| **2.5 min** (150s) | **7.5 min** (450s) | Backlight Dim | `dim` | Reduces screen brightness to 5% (`brightnessctl -s set 5%`); automatically restored on user input (`brightnessctl -r`). |
| **5 min** (300s) | **15 min** (900s) | Screen Lock | `lock` | Triggers Noctalia's built-in session lock. |
| **5.5 min** (330s) | **16.5 min** (990s) | Screen Off | `screen-off` | Powers down displays via Wayland DPMS; wakes automatically on input. |
| **5.5 min** (330s) | *N/A* | Keyboard Light *(Framework 16)* | `kb-backlight` | Turns off keyboard backlight (`kb-light-manager off 32ac 0012`); restores on activity. |
| **10 min** (600s) | *N/A* | Suspend *(Framework 16)* | `suspend-then-hibernate` | Executes `systemctl suspend-then-hibernate`. |

> [!NOTE]
> Sleep and lid-close events are monitored directly via `systemd-logind` (`PrepareForSleep` delay inhibitors), ensuring the screen is locked before the system suspends regardless of idle status.
