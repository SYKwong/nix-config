# Managing Desktop Entries

This directory manages custom desktop entries and hides unwanted application shortcuts from application launchers (such as Noctalia).

## Files
- [`add-desktop-entry.nix`](./add-desktop-entry.nix): Declares custom `.desktop` entries (e.g., web app wrappers like LINE).
- [`hide-desktop-entry.nix`](./hide-desktop-entry.nix): Hides entries using two tiers depending on how the application installs its `.desktop` file.

---

## Hiding Desktop Entries in [`hide-desktop-entry.nix`](./hide-desktop-entry.nix)

### 1. `appsToHide` (Standard / Home Manager)
For standard NixOS and Home Manager packages whose `.desktop` files live in `/run/current-system/sw/share/applications/` or the user profile.

Adding an entry name to `appsToHide` generates a shadow entry with `NoDisplay=true` via Home Manager's `xdg.desktopEntries`:

```nix
appsToHide = [
  "btop"
  "mpv"
  "qimgv"
  "foot"
  # ...
];
```

### 2. `annoyingApps` (Forced User-Level Override)
Some external tools write `.desktop` files directly to `~/.local/share/applications/` (e.g. Waydroid Google apps) or ignore Home Manager's `xdg.desktopEntries`. Because entries placed directly in `~/.local/share/applications/` have higher XDG priority, standard shadowing may fail.

For these stubborn apps, add the name (without `.desktop`) to `annoyingApps`. It uses `home.file` with `force = true` to overwrite `~/.local/share/applications/<name>.desktop` with `NoDisplay=true` and `Hidden=true`:

```nix
annoyingApps = [
  "rofi"
  "rofi-theme-selector"
  "waydroid.com.android.vending"
];
```

---

## Finding Desktop Entry Names

To find the exact name of an entry to hide:

1. **System packages**:
   ```bash
   ls /run/current-system/sw/share/applications | grep -i <app-name>
   ```

2. **User-level or runtime packages (Waydroid, Flatpak, local installs)**:
   ```bash
   ls ~/.local/share/applications | grep -i <app-name>
   ```

3. Add the basename (excluding `.desktop`) to `appsToHide`, or to `annoyingApps` if it still appears in the launcher.
