# Desktop Entries (`home/misc/`)

Quick reference for declaring custom `.desktop` launchers and hiding unwanted application shortcuts from Noctalia.

---

## Directory Taxonomy

| File                                                 | Description                                                                                                      |
| :--------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------- |
| [`add-desktop-entry.nix`](./add-desktop-entry.nix)   | Declares custom `.desktop` entries (e.g. LINE web app wrapper, NordVPN XWayland override).                       |
| [`hide-desktop-entry.nix`](./hide-desktop-entry.nix) | Hides unwanted desktop entries via standard shadowing (`appsToHide`) or forced local overrides (`annoyingApps`). |
| [`desktop-cache.nix`](./desktop-cache.nix)           | Activation hook (`pruneKsycoca`) that purges `~/.cache/ksycoca6*` and restarts `plasma-dolphin.service`.         |
| [`dotfile.nix`](./dotfile.nix)                       | Out-of-store `~/.config/` symlink declarations (`mkOutOfStoreSymlink`).                                          |

---

## Hiding Entries (`hide-desktop-entry.nix`)

1. **`appsToHide` (Standard NixOS / Home Manager packages)**:
   Generates a shadow entry with `OnlyShowIn = "X-None;"` via `xdg.desktopEntries`:
   ```nix
   appsToHide = [ "btop" "mpv" "qimgv" "foot" ];
   ```
2. **`annoyingApps` (Stubborn user-level entries in `~/.local/share/applications/`)**:
   Overwrites `~/.local/share/applications/<name>.desktop` with `NoDisplay=true` and `Hidden=true` via `home.file` (`force = true`):
   ```nix
   annoyingApps = [ "rofi" "waydroid.com.android.vending" ];
   ```

---

## Quick Lookup Commands

```bash
# Find .desktop files by filename across system, user profile, and local paths:
find /run/current-system/sw/share/applications \
     /etc/profiles/per-user/$USER/share/applications \
     ~/.local/share/applications \
     -name "*<app-name>*.desktop" 2>/dev/null

# Find .desktop files by launcher display title (Name=):
grep -rn -i "^Name=<Display Name>" \
  /run/current-system/sw/share/applications \
  /etc/profiles/per-user/$USER/share/applications \
  ~/.local/share/applications 2>/dev/null
```

Use the matched filename **without `.desktop`** (e.g. `org.kde.ark.desktop` → `"org.kde.ark"`).

---

## Documentation

For architectural details on the two-tier XDG shadowing priority, KSycoca `1970-01-01` timestamp invalidation, and custom icon theming, refer to the online guide:

📖 **[Managing Desktop Entries Documentation](https://nix.kyle-kwong.com/nix-config/desktop-entries/)**
