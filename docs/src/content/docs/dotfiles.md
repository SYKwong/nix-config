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
| **`kitty/`** | `~/.config/kitty` | Kitty terminal emulator configuration, color schemes, and declarative session blueprints (e.g. `two-pane.session`, `three-pane.session`). |
| **`foot/`** | `~/.config/foot` | Minimal Foot terminal configuration used for floating TUI wrappers (`tui-wrap`). |
| **`starship/`** | `~/.config/starship.toml` | Starship cross-shell prompt theme and format settings. |
| **`kde/dolphin/`** | `~/.config/dolphinrc`, `kservicemenurc` | KDE Dolphin file manager preferences and context menus (mutable dolphinstaterc is seeded via post-install). |
| **`feishin/`** | `~/.config/feishin/config.json` | Feishin desktop music player preferences and lyrics sources. |
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

---

## Hyprland Window Rules & Media Rendering

### Selective Tab Opacity for Zen Browser (`config/hypr/hyprland/windowrule.lua`)

In Hyprland, global window decorations (`config/hypr/hyprland/looknfeel.lua`) enforce an active opacity multiplier (`active_opacity = 0.95`) and 3-pass dual-kawase blur. While this provides a clean frosted-glass aesthetic for terminal buffers and code editors, it degrades in-tab video playback by allowing desktop wallpaper patterns and underlying windows to bleed into the video frame, crushing black levels.

#### The Architectural Difference: Gecko vs. Chromium

- **Chromium / Helium (`UseOzonePlatform`)**: Promotes video players into independent Wayland subsurfaces (`wl_subsurface`). Video quads remain 100% opaque regardless of the compositor's window-level alpha multiplier.
- **Gecko / Zen Browser (`WebRender`)**: Flattens the entire web page, DOM overlays, and `<video>` tags into a single unified top-level `wl_surface`. Hyprland applies the 0.95 alpha multiplier across the entire buffer indiscriminately, which previously forced users to fullscreen videos to trigger `fullscreen-force-opaque`.

#### The Declarative Helper (`make_browser_tab_opaque`)

Rather than forcing the entire browser permanently opaque—which sacrifices translucency during normal browsing—`config/hypr/hyprland/windowrule.lua` implements `make_browser_tab_opaque`:

```lua
local function make_browser_tab_opaque(title_keyword, browser_class)
	local target_browser_class <const> = browser_class or "zen-beta"

	hl.window_rule({
		name = "opaque-zen-tab-" .. string.lower(title_keyword),
		match = {
			class = target_browser_class,
			title = ".*" .. title_keyword .. " — Zen Browser.*",
		},
		opacity = 1.0,
		opaque = true,
	})
end

make_browser_tab_opaque("YouTube")
```

- **Scoped Title Regex**: Scopes title matching to `.*<Keyword> — Zen Browser.*` to prevent false positives from other desktop applications while matching both browse and video playback pages (e.g., `<Video Title> - YouTube — Zen Browser`).
- **Targeted Opacity Override**: Forces `opacity = 1.0` and `opaque = true` only when a targeted media tab is active, delivering true black levels and solid video in tiled/windowed mode.
- **Extensible Site Registration**: New media streaming services can be registered one by one:
  ```lua
  make_browser_tab_opaque("Twitch")
  make_browser_tab_opaque("Netflix")
  ```

