# Home Manager User Configuration (`home/`)

This directory contains pure **Home Manager** user-space configurations. Everything defined here operates within the user environment (`programs.*`, `home.*`, `xdg.*`) and is imported automatically across all hosts via [`modules/home-manager/default.nix`](../modules/home-manager/default.nix).

---

## Directory Taxonomy

| Category | Description |
| :--- | :--- |
| **`core/`** | Baseline user environment configuration (`xdg.userDirs`, default folder structures). |
| **`cli/`** | Terminal utilities and CLI tools (`bat`, `btop`, `eza`, `fastfetch`, `fzf`, `git`, `yazi`, `zoxide`, `antigravity`). |
| **`desktop/`** | Noctalia desktop shell (status bar, OSD, lockscreen, runner, idle management). |
| **`browsers/`** | Web browsers (Zen Browser, Helium). |
| **`editors/`** | Text editors, primarily NixVim (declarative Neovim configuration) and Zed. |
| **`media/`** | Media players and desktop streaming clients (`feishin`, `mpv`, `jellyfin-desktop`). |
| **`shell/`** | Fish shell configuration, interactive prompts, completions, and shell aliases/functions (`alias.nix`). |
| **`social/`** | Messaging and social clients (`vesktop`). |
| **`theme/`** | GTK theme settings and Stylix user-level overrides. |
| **`misc/`** | System glue: out-of-store dotfile symlinking (`dotfile.nix`), and custom/hidden `.desktop` entries. |

---

## Key Conventions

### 1. User Scope Purity
Files in this directory must only declare Home Manager options. Never declare system-level options like `environment.systemPackages` or `services.*` (unless they are under `services` in Home Manager). User changes take effect when rebuilt via `nrs` (NixOS-Rebuild Switch).

### 2. Live Out-of-Store Dotfiles
Fast-iterating configuration files (such as Hyprland Lua scripts, Kitty, and Foot configurations) are **not** baked into the read-only Nix store. Instead, they reside in [`config/`](../config) and are symlinked out-of-store via [`home/misc/dotfile.nix`](./misc/dotfile.nix). This allows making live edits and reloading applications instantly without rebuilding NixOS.

### 3. Desktop Entries
Custom desktop launchers and rules for hiding unwanted third-party app shortcuts are managed in [`home/misc/`](./misc). See [`home/misc/desktop-entry.md`](./misc/desktop-entry.md) for documentation on the two-tier hiding mechanism.

### 4. Host-Specific User Extensions
All machines import this common [`home/`](./) directory directly via [`modules/home-manager/default.nix`](../modules/home-manager/default.nix). If a machine requires user packages or settings unique to that host, place them in `hosts/<hostname>/home/` (with a `default.nix`), which is automatically imported if it exists.

### 5. Idle Management
Idle timeouts and power states are managed natively by Noctalia ([`home/desktop/noctalia.nix`](./desktop/noctalia.nix)) using the Wayland `ext_idle_notifier_v1` protocol, dynamically scaling between laptops (1x) and desktops/HTPCs (3x multiplier):
- **Laptop Baseline (1x)**: 2.5 min screen dim (`brightnessctl -s set 5%`) → 5 min lock → 5.5 min screen off (DPMS) → 10 min suspend.
- **Desktop Scaled (3x)**: 7.5 min screen dim → 15 min lock → 16.5 min screen off.

---

## Developer Quick Reference

### 1. Adding a New CLI Utility or App
- Declare standalone programs in [`home/cli/default.nix`](./cli/default.nix) via `programs.<name>.enable = true;` or append to `home.packages = with pkgs; [ <name> ];`.
- For GUI or desktop apps, check the appropriate category (`browsers/`, `editors/`, `media/`, `social/`).

### 2. Modifying Shell Aliases & Environment
- Interactive shell aliases and functions are declared in [`home/shell/alias.nix`](./shell/alias.nix) (e.g. `nrs`, `git lazy`).

### 3. Applying Changes
- Rebuild and activate user generation:
  ```bash
  nrs
  ```

---

## Documentation

For full details on desktop entries, declarative application state merging, category-scoped playlists, and Atuin shell history sync, refer to the online guide:

📖 **[Home Manager User Configuration](https://nix.kyle-kwong.com/home-manager/)**
