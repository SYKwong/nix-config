# Home Manager User Configuration (`home/`)

This directory contains pure **Home Manager** user-space configurations. Everything defined here operates within the user environment (`programs.*`, `home.*`, `xdg.*`) and is imported automatically across all hosts via [`modules/home-manager/default.nix`](../modules/home-manager/default.nix).

---

## Directory Taxonomy

| Category | Description |
| :--- | :--- |
| **`cli/`** | Terminal utilities and CLI tools (`bat`, `btop`, `eza`, `fastfetch`, `fzf`, `git`, `yazi`, `zoxide`, `antigravity`). |
| **`desktop/`** | Noctalia desktop shell (status bar, OSD, lockscreen, runner) and Hypridle idle daemon. |
| **`browsers/`** | Web browsers (Zen Browser, Helium). |
| **`editors/`** | Text editors, primarily NixVim (declarative Neovim configuration) and Zed. |
| **`shell/`** | Fish shell configuration, interactive prompts, and completions. |
| **`social/`** | Messaging and social clients (`vesktop`). |
| **`theme/`** | GTK theme settings and Stylix user-level overrides. |
| **`misc/`** | System glue: out-of-store dotfile symlinking (`dotfile.nix`), custom/hidden `.desktop` entries, and shell aliases. |

---

## Key Conventions

### 1. User Scope Purity
Files in this directory must only declare Home Manager options. Never declare system-level options like `environment.systemPackages` or `services.*` (unless they are under `services` in Home Manager, like `services.hypridle`). User changes take effect when rebuilt via `nrs` (NixOS-Rebuild Switch).

### 2. Live Out-of-Store Dotfiles
Fast-iterating configuration files (such as Hyprland Lua scripts, Kitty, and Foot configurations) are **not** baked into the read-only Nix store. Instead, they reside in [`config/`](../config) and are symlinked out-of-store via [`home/misc/dotfile.nix`](./misc/dotfile.nix). This allows making live edits and reloading applications instantly without rebuilding NixOS.

### 3. Desktop Entries
Custom desktop launchers and rules for hiding unwanted third-party app shortcuts are managed in [`home/misc/`](./misc). See [`home/misc/desktop-entry.md`](./misc/desktop-entry.md) for documentation on the two-tier hiding mechanism.

### 4. Host-Specific User Extensions
Host directories do not contain separate `home.nix` files; all machines import this common [`home/`](./) directory directly via [`modules/home-manager/default.nix`](../modules/home-manager/default.nix). If a machine requires user packages or settings unique to that host, declare them under `extraHomeModules` in [`outputs.nix`](../outputs.nix).
