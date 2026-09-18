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

Desktop entries often use Reverse-DNS names that differ from their package name or display title (e.g., Amberol is `io.bassi.Amberol.desktop`, Ark is `org.kde.ark.desktop`).

To find the exact `.desktop` filename to hide:

### Method 1: Search by filename across active desktop directories
Search across System, Home Manager user profile, and local directories simultaneously:

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
3. **User-level or runtime packages (Waydroid, Flatpak, local installs)**:
   ```bash
   ls ~/.local/share/applications | grep -i <app-name>
   ```

### Method 2: Search by launcher display title
If you only know the friendly name displayed in your launcher (e.g. "Amberol" or "Archive Manager"), search for the `Name=` field inside all `.desktop` files:

```bash
grep -rn -i "^Name=<Display Name>" \
  /run/current-system/sw/share/applications \
  /etc/profiles/per-user/$USER/share/applications \
  ~/.local/share/applications 2>/dev/null
```

### Applying the Name
Take the filename **excluding `.desktop`**:
- `/etc/profiles/per-user/$USER/share/applications/io.bassi.Amberol.desktop` $\rightarrow$ `"io.bassi.Amberol"`
- `/run/current-system/sw/share/applications/org.kde.ark.desktop` $\rightarrow$ `"org.kde.ark"`

Add that exact string to `appsToHide` in [`hide-desktop-entry.nix`](./hide-desktop-entry.nix), or to `annoyingApps` if it still appears in the launcher.
