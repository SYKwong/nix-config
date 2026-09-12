# Application Configurations (`config/`)

This directory contains raw, non-Nix configuration files (written in Lua, Conf, TOML, and INI). Most of these files are symlinked directly to `~/.config/` out-of-store, while certain configs (notably Starship) are ingested at Nix evaluation time.

---

## Out-of-Store Symlinks

Standard NixOS / Home Manager configurations bake dotfiles directly into `/nix/store/` as read-only files. Modifying a setting would require running `nrs` (NixOS-Rebuild Switch) and waiting for evaluation.

By using `config.lib.file.mkOutOfStoreSymlink` in [`home/misc/dotfile.nix`](../home/misc/dotfile.nix), these files point directly back to this repository directory (`./config/...`).

### Advantages:
1. **Instant Feedback:** You can edit a keybinding or color scheme and reload the application immediately (e.g. `hyprctl reload` or Kitty `Ctrl + Shift + F5`) without rebuilding NixOS.
2. **Version Controlled:** All dotfiles remain tracked by git inside this repository.

---

## Exception: In-Store Evaluated Configurations (Starship)

Not every configuration in this directory is symlinked out-of-store.

Specifically, [`starship/starship.toml`](./starship/starship.toml) is read at Nix evaluation time via `fromTOML (builtins.readFile ../../config/starship/starship.toml)` inside [`home/shell/fish.nix`](../home/shell/fish.nix) and written into the Nix store:
* **Why**: Starship settings are managed and validated declaratively through Home Manager's `programs.starship` module.
* **Rebuild Required**: Unlike out-of-store symlinks, changes to `starship.toml` require running `nrs` to evaluate the new configuration and update the generated file.

---

## Managed Configurations

| Directory | Target Destination | Deployment Method | Description |
| :--- | :--- | :--- | :--- |
| **`hypr/`** | `~/.config/hypr` | Out-of-store symlink | Hyprland compositor configuration written in pure Lua (keybinds, window rules, layer rules, animations, layout utilities). |
| **`kitty/`** | `~/.config/kitty` | Out-of-store symlink | Kitty terminal emulator configuration, color schemes, and declarative session blueprints (e.g. `three-pane.session`). |
| **`foot/`** | `~/.config/foot` | Out-of-store symlink | Minimal Foot terminal configuration used for floating TUI wrappers (`tui-wrap`). |
| **`starship/`** | Nix Store (`~/.config/starship.toml`) | Evaluated via `fromTOML` in [`home/shell/fish.nix`](../home/shell/fish.nix) | Starship cross-shell prompt theme and format settings (requires `nrs` on change). |
| **`kde/dolphin/`** | `~/.config/dolphinrc`, `kservicemenurc` | Out-of-store symlink | KDE Dolphin file manager preferences and context menu integration. |
| **`qimgv/`** | `~/.config/qimgv/qimgv.conf` | Out-of-store symlink | Fast image viewer settings. |
| **`glow/`** | `~/.config/glow` | Out-of-store symlink | CLI Markdown viewer theme and pager settings. |

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
