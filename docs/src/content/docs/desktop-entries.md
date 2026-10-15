---
title: Managing Desktop Entries
description: Managing custom desktop application launchers and hiding unwanted shortcuts in Noctalia.
---

This guide explains how to manage custom desktop application launchers and how to hide unwanted shortcuts from application runners (such as Noctalia) via `home/misc/`.

---

## Architecture & Configuration Files

- **`add-desktop-entry.nix`**: Declares custom `.desktop` entries (such as web application wrappers like LINE).
- **`hide-desktop-entry.nix`**: Provides a two-tier mechanism to suppress unwanted application icons.

---

## Two-Tier Hiding Mechanism

Different applications deploy `.desktop` files into different XDG system and user paths. To account for this, hiding is implemented in two tiers:

### Tier 1: `appsToHide` (Standard / Home Manager)
For standard NixOS system packages and Home Manager applications whose `.desktop` files live in `/run/current-system/sw/share/applications/` or the user profile.

Adding an entry name to `appsToHide` generates a shadow entry with `OnlyShowIn = "X-None;"` via Home Manager's `xdg.desktopEntries` to hide it from desktop application launchers (like Noctalia):

```nix
appsToHide = [
  "btop"
  "mpv"
  "qimgv"
  "foot"
  # ...
];
```

### Tier 2: `annoyingApps` (Forced User-Level Override)
Some external runtimes (such as Waydroid or Steam) write `.desktop` files directly into `~/.local/share/applications/`. Because files in `~/.local/share/applications/` have higher XDG precedence than `/run/current-system`, standard Home Manager shadowing cannot override them.

For these stubborn entries, add the identifier (without `.desktop`) to `annoyingApps`. It uses Home Manager's `home.file` with `force = true` to overwrite `~/.local/share/applications/<name>.desktop` with `NoDisplay=true` and `Hidden=true`:

```nix
annoyingApps = [
  "rofi"
  "rofi-theme-selector"
  "waydroid.com.android.vending"
];
```

---

## Finding Desktop Entry Names

Desktop entries often use Reverse-DNS names that differ from their binary name or friendly title (e.g., Amberol is `io.bassi.Amberol.desktop`, Ark is `org.kde.ark.desktop`).

### Method 1: Search by Filename
Search across the system profile, Home Manager profile, and local directories simultaneously:

```bash
find /run/current-system/sw/share/applications \
     /etc/profiles/per-user/$USER/share/applications \
     ~/.local/share/applications \
     -name "*<app-name>*.desktop" 2>/dev/null
```

Or query specific directories:
1. **System packages (`environment.systemPackages`)**:
   ```bash
   ls /run/current-system/sw/share/applications | grep -i <app-name>
   ```
2. **Home Manager packages (`home.packages`)**:
   ```bash
   ls /etc/profiles/per-user/$USER/share/applications | grep -i <app-name>
   ```
3. **User-level runtimes (Waydroid, Flatpak, local installs)**:
   ```bash
   ls ~/.local/share/applications | grep -i <app-name>
   ```

### Method 2: Search by Launcher Display Title
If you only know the friendly name displayed in your launcher (e.g. "Amberol" or "Archive Manager"), search for the `Name=` field inside all `.desktop` files:

```bash
grep -rn -i "^Name=<Display Name>" \
  /run/current-system/sw/share/applications \
  /etc/profiles/per-user/$USER/share/applications \
  ~/.local/share/applications 2>/dev/null
```

### Applying the Entry Name
Take the matched filename **excluding `.desktop`**:
- `/etc/profiles/per-user/$USER/share/applications/io.bassi.Amberol.desktop` → `"io.bassi.Amberol"`
- `/run/current-system/sw/share/applications/org.kde.ark.desktop` → `"org.kde.ark"`

Add that exact string to `appsToHide` in `home/misc/hide-desktop-entry.nix`, or to `annoyingApps` if it persists.

---

## Application Icons

Custom application icons are centralized under the top-level `icons/` directory:
- `icons/Line.png`: Launcher icon for the LINE Chrome web app desktop shortcut (`home/misc/add-desktop-entry.nix`).
- `icons/protontricks.svg`: Scalable SVG icon for Protontricks (`modules/gaming/default.nix`), automatically resized into standard hicolor icon themes (16×16 to 256×256) during package build.

*Note: `icons/protontricks.svg` uses the Wine icon from the KDE Breeze Icons theme, licensed under [LGPL-3.0-or-later](https://invent.kde.org/frameworks/breeze-icons/-/blob/master/COPYING-ICONS) by the KDE Community.*
