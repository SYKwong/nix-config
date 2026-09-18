# Application Configurations (`config/`)

This directory contains raw, non-Nix configuration files (written in Lua, Conf, TOML, and INI). All files are symlinked directly to `~/.config/` out-of-store via [`home/misc/dotfile.nix`](../home/misc/dotfile.nix).

---

## Out-of-Store Symlinks

Standard NixOS / Home Manager configurations bake dotfiles directly into `/nix/store/` as read-only files. Modifying a setting would require running `nrs` (NixOS-Rebuild Switch) and waiting for evaluation.

By using `config.lib.file.mkOutOfStoreSymlink` in [`home/misc/dotfile.nix`](../home/misc/dotfile.nix), these files point directly back to this repository directory (`./config/...`).

### Advantages:
1. **Instant Feedback:** You can edit a keybinding or color scheme and reload the application immediately (e.g. `hyprctl reload` or Kitty `Ctrl + Shift + F5`) without rebuilding NixOS.
2. **Version Controlled:** All dotfiles remain tracked by git inside this repository.

---

---

## Managed Configurations

| Directory | Target Destination | Description |
| :--- | :--- | :--- |
| **`hypr/`** | `~/.config/hypr` | Hyprland compositor configuration written in pure Lua (keybinds, window rules, layer rules, animations, layout utilities). |
| **`kitty/`** | `~/.config/kitty` | Kitty terminal emulator configuration, color schemes, and declarative session blueprints (e.g. `three-pane.session`). |
| **`foot/`** | `~/.config/foot` | Minimal Foot terminal configuration used for floating TUI wrappers (`tui-wrap`). |
| **`starship/`** | `~/.config/starship.toml` | Starship cross-shell prompt theme and format settings. |
| **`kde/dolphin/`** | `~/.config/dolphinrc`, `kservicemenurc`, `~/.local/state/dolphinstaterc` | KDE Dolphin file manager preferences, context menus, and window/panel layout state. |
| **`qimgv/`** | `~/.config/qimgv/qimgv.conf` | Fast image viewer settings. |
| **`glow/`** | `~/.config/glow` | CLI Markdown viewer theme and pager settings. |

---
## Adding a New Out-of-Store Dotfile
1. Create the configuration file or folder in `./config/<app>/`.
2. Register the mapping in [`home/misc/dotfile.nix`](../home/misc/dotfile.nix) under the `files` attribute set:
   ```nix
   files = {
     "my-app/config.conf" = "my-app/config.conf";
   };
   ```
3. Run `nrs` once to establish the initial symlink in `~/.config/`.
