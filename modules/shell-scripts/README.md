# Custom Shell Scripts (`modules/shell-scripts/`)

This directory contains custom CLI tools and helper scripts packaged as native Nix derivations and added to `environment.systemPackages`.

---

## Existing Scripts

| Script | Entry File | Derivation Builder | Description |
| :--- | :--- | :--- | :--- |
| **`rebuild`** (alias: **`nrs`**) | [`rebuild.nix`](./rebuild.nix) | `writeShellApplication` | NixOS configuration rebuild engine that formats code, verifies fleet configurations evaluate cleanly (excluding installer), creates a boot entry via `nh os boot`, activates live via `switch-to-configuration`, and checks for pending kernel reboots (with a 10s auto-skip prompt). Run via alias `nrs`. |
| **`post-install`** | [`post-install.nix`](./post-install.nix) | `writeShellApplication` | Post-installation onboarding engine for TPM2 auto-unlock enrollment, host/user SSH key generation, agenix secret rekeying, and forge authentication. |
| **`hypr-virtual-monitor`** | [`hypr-virtual-monitor.nix`](./hypr-virtual-monitor.nix) | `writeShellApplication` | Dynamic headless virtual monitor controller and idle socket watchdog for Hyprland and Sunshine streaming (`start`, `stop`, `toggle`, `watchdog`). |
| **`rofi-keybinds`** | [`rofi-keybind.nix`](./rofi-keybind.nix) | `writeShellApplication` | Dynamic cheat sheet parsed from `hyprctl binds` and displayed in an interactive Rofi dmenu (`SUPER + SHIFT + /` or `SUPER + F1`). |
| **`kb-light-manager`** | [`kb-light-manager.nix`](./kb-light-manager.nix) | `writeShellApplication` | Framework laptop keyboard backlight toggle and brightness manager using `qmk_hid`. |
| **`display-brightness`** | [`display-brightness.nix`](./display-brightness.nix) | `writeShellApplication` | Display brightness manager targeting focused internal display backlight with automatic fallback to `hyprsunset` software dimming for external monitors. |
| **`update-wallpaper`** (alias: **`nwall`**) | [`update-wallpaper.nix`](./update-wallpaper.nix) | `writeShellApplication` | Automated wallpaper synchronization pipeline: auto-resolves wallpaper source repo (prioritizing `~/Projects/private-wallpaper`), pushes local changes, updates `wallpapers` flake input, rebuilds system live (`nrs`), and submits auto-merging MR. |
| **`safe-python`** | [`safe-python.nix`](./safe-python.nix) | `writeShellApplication` | Kernel-sandboxed Python test runner using Bubblewrap (`bwrap`). Runs Python with an immutable read-only root (`--ro-bind / /`), memory tmpfs (`/tmp`), unshared network/PID namespaces, scrubbed environment (`--clearenv`), and masked user credentials. |
| **`safe-npm`** | [`safe-npm.nix`](./safe-npm.nix) | `writeShellApplication` | Supply-chain protected NPM package manager using Bubblewrap. Confines writes to `$PWD`, scrubs environment secrets (`--clearenv`), and masks credentials (`~/.ssh`, `~/.gnupg`, etc.). |
| **`safe-npx`** | [`safe-npx.nix`](./safe-npx.nix) | `writeShellApplication` | Supply-chain protected NPX tool executor using Bubblewrap. Confines tool execution and writes to `$PWD`, scrubs environment secrets, and masks user credentials. |
| **`tui-wrap`** | [`tui-wrap.nix`](./tui-wrap.nix) | `writeShellScriptBin` *(Exception)* | Helper to spawn arbitrary CLI and TUI tools (like Yazi or Btop) inside floating Foot terminal surfaces. Dynamically resolves user commands from runtime `PATH`. |

---

## Authoring Standard: `writeShellApplication`

Custom scripts in this directory should standardly use `pkgs.writeShellApplication` rather than raw string scripts:

```nix
{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "my-script";

  # Strictly declare all CLI binaries required by the script in PATH:
  runtimeInputs = with pkgs; [
    coreutils
    curl
    jq
  ];

  text = ''
    # Shellcheck is automatically run by writeShellApplication at build time.
    set -euo pipefail

    echo "Hello, world!"
  '';
}
```

### Why this standard is enforced:
1. **ShellCheck Verification**: `writeShellApplication` runs `shellcheck` during evaluation/build, catching syntax errors and unquoted variables early.
2. **Deterministic PATH**: Binaries listed in `runtimeInputs` are wrapped into the script's `PATH`, eliminating runtime "command not found" errors regardless of user environment.
3. **No Redundant PATH Checks**: Avoid defensive `command -v` checks inside the script for tools declared in `runtimeInputs`.

### Exception: `tui-wrap` (`writeShellScriptBin`)
[`tui-wrap.nix`](./tui-wrap.nix) is an intentional exception that uses `pkgs.writeShellScriptBin`. Because `tui-wrap` is a general launcher designed to execute arbitrary user binaries passed at runtime (`command -v "$APP_NAME"`), its target executables cannot be known ahead of time or statically declared in `runtimeInputs`.

---

## Registering a New Script
1. Create `./modules/shell-scripts/<script-name>.nix`.
2. Import it in [`modules/shell-scripts/default.nix`](./default.nix) under the `scripts` set to automatically expose it in `environment.systemPackages`.

---

## Documentation

For full details on authoring shell scripts, runtime environment wrapping, and existing utilities, refer to the online guide:

📖 **[Custom Shell Scripts Documentation](https://nix.kyle-kwong.com/shell-scripts/)**
