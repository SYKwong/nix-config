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
| **`cli/`** | `home/cli/` | Terminal utilities (`bat`, `btop`, `eza`, `fastfetch`, `fzf`, `git`, `yazi`, `zoxide`, `antigravity`). |
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
- **`mpv`**: General media player configured with `autocreate-playlist = "same"`. Opening an audio file automatically enqueues only neighboring audio tracks from the parent folder; opening a video file only enqueues neighboring video tracks.
- **`jellyfin-desktop`**: TV and movie streaming from local Jellyfin media servers.

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
