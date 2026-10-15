---
title: Out-of-Store Dotfiles
description: Fast-iterating dotfile workflow with live out-of-store symlinks into ~/.config/ without rebuilds.
---

This directory contains raw, non-Nix configuration files (written in Lua, Conf, TOML, and INI). All files are symlinked directly to `~/.config/` out-of-store via `home/misc/dotfile.nix`.

---

## The Out-of-Store Symlink Philosophy

Standard NixOS and Home Manager setups bake configuration files directly into `/nix/store/` as read-only symlinks. While deterministic, this creates significant friction: modifying a single keybinding, prompt style, or color scheme requires executing `nrs` (NixOS-Rebuild Switch) and waiting for full flake evaluation.

By utilizing Home Manager's `config.lib.file.mkOutOfStoreSymlink`, these files point directly to the live repository working tree (`~/nix-config/config/...`).

### Key Advantages:
1. **Instant Feedback:** You can edit a keybinding, window rule, or palette and reload the application immediately (e.g. `hyprctl reload` or Kitty `Ctrl + Shift + F5`) without rebuilding NixOS.
2. **Version Controlled:** All dotfiles remain tracked by git inside this repository.
3. **No Drift:** Changes made in the live configuration are already in your local git tree, ready to be committed with `git lazy`.

---

## Managed Configurations

| Application / Directory | Target Destination in `$HOME` | Description |
| :--- | :--- | :--- |
| **`hypr/`** | `~/.config/hypr` | Hyprland compositor configuration written in pure Lua (keybindings, window rules, layer rules, animations, and monitor layout utilities). |
| **`kitty/`** | `~/.config/kitty` | Kitty terminal emulator configuration, color schemes, and declarative session blueprints (e.g. `three-pane.session`). |
| **`foot/`** | `~/.config/foot` | Minimal Foot terminal configuration used for floating TUI wrappers (`tui-wrap`). |
| **`starship/`** | `~/.config/starship.toml` | Starship cross-shell prompt theme and format settings. |
| **`kde/dolphin/`** | `~/.config/dolphinrc`, `kservicemenurc` | KDE Dolphin file manager preferences and context menus (mutable dolphinstaterc is seeded via post-install). |
| **`feishin/`** | `~/.config/feishin/config.json` | Feishin desktop music player preferences and lyrics sources. |
| **`zen/`** | `~/.config/zen/default/chrome/zen-themes.css` | Zen Browser custom CSS theme and user styles. |
| **`qimgv/`** | `~/.config/qimgv/qimgv.conf` | Fast image viewer preferences and keyboard bindings. |
| **`glow/`** | `~/.config/glow` | CLI Markdown viewer theme and pager settings. |

---

## Adding a New Out-of-Store Dotfile

1. Create the configuration file or folder in `./config/<app>/`.
2. Register the mapping in `home/misc/dotfile.nix` under the `files` attribute set:
   ```nix
   files = {
     "my-app/config.conf" = "my-app/config.conf";
   };
   ```
3. Run `nrs` once to establish the initial symlink in `~/.config/`.
4. Subsequent edits to `./config/my-app/config.conf` take effect immediately without rebuilding.
