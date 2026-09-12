# Custom Shell Scripts (`modules/shell-scripts/`)

This directory contains custom CLI tools and helper scripts packaged as native Nix derivations and added to `environment.systemPackages`.

---

## Existing Scripts

| Script | Entry File | Derivation Builder | Description |
| :--- | :--- | :--- | :--- |
| **`rebuild`** (alias: **`nrs`**) | [`rebuild.nix`](./rebuild.nix) | `writeShellApplication` | NixOS configuration rebuild engine with health checks, formatters, automated commit messages, and boot/switch modes. Run via alias `nrs` (NixOS-Rebuild Switch). |
| **`rofi-keybinds`** | [`rofi-keybind.nix`](./rofi-keybind.nix) | `writeShellApplication` | Dynamic cheat sheet parsed from `hyprctl binds` and displayed in an interactive Rofi dmenu (`SUPER + H`). |
| **`kb-light-manager`** | [`kb-light-manager.nix`](./kb-light-manager.nix) | `writeShellApplication` | Framework laptop keyboard backlight toggle and brightness manager using `qmk_hid`. |
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
