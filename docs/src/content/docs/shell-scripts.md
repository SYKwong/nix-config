---
title: Custom Shell Scripts
description: Custom CLI tools and system management utilities packaged as native Nix derivations.
---

This directory (`modules/shell-scripts/`) contains custom CLI tools and system management utilities packaged as native Nix derivations and added directly to `environment.systemPackages`.

---

## Existing Scripts

| Script | Entrypoint File | Builder | Description |
| :--- | :--- | :--- | :--- |
| **`rebuild`** (alias: **`nrs`**) | `modules/shell-scripts/rebuild.nix` | `writeShellApplication` | NixOS configuration rebuild engine that formats code, stages a boot entry via `nh os boot`, activates live via `switch-to-configuration`, and checks for pending kernel reboots. Run via alias `nrs`. |
| **`deploy`** | `modules/shell-scripts/deploy.nix` | `writeShellApplication` | Remote peer NixOS deployment tool that builds configurations locally and pushes live or staged updates across local LAN via SSH and mDNS. |
| **`hypr-virtual-monitor`** | `modules/shell-scripts/hypr-virtual-monitor.nix` | `writeShellApplication` | Dynamic headless virtual monitor controller and idle socket watchdog for Hyprland and Sunshine streaming (`start`, `stop`, `toggle`, `watchdog`). |
| **`display-brightness`** | `modules/shell-scripts/display-brightness.nix` | `writeShellApplication` | Display brightness manager targeting focused internal display backlight with automatic fallback to `hyprsunset` software dimming for external monitors. |
| **`rofi-keybinds`** | `modules/shell-scripts/rofi-keybind.nix` | `writeShellApplication` | Dynamic cheat sheet parsed from `hyprctl binds` and displayed in an interactive Rofi dmenu (`SUPER + SHIFT + /` or `SUPER + F1`). |
| **`kb-light-manager`** | `modules/shell-scripts/kb-light-manager.nix` | `writeShellApplication` | Framework laptop keyboard backlight toggle and brightness manager using `qmk_hid`. |
| **`tui-wrap`** | `modules/shell-scripts/tui-wrap.nix` | `writeShellScriptBin` *(Exception)* | Helper to spawn arbitrary CLI and TUI tools (like Yazi or Btop) inside floating Foot terminal surfaces. Dynamically resolves user commands from runtime `PATH`. |

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
    # ShellCheck is automatically run by writeShellApplication at build time.
    set -euo pipefail

    echo "Hello, world!"
  '';
}
```

### Why this standard is enforced:
1. **Build-Time ShellCheck Verification:** `writeShellApplication` runs `shellcheck` during evaluation and build, catching syntax errors, unquoted variables, and bash anti-patterns early.
2. **Deterministic `PATH` Wrapping:** Binaries listed in `runtimeInputs` are wrapped into the script's `PATH`, eliminating runtime "command not found" errors regardless of the user's interactive environment.
3. **No Redundant PATH Checks:** Avoid defensive `command -v` checks inside the script for tools declared in `runtimeInputs`.

### Exception: `tui-wrap` (`writeShellScriptBin`)
`tui-wrap.nix` is an intentional exception that uses `pkgs.writeShellScriptBin`. Because `tui-wrap` is a general launcher designed to execute arbitrary user binaries passed at runtime (`command -v "$APP_NAME"`), its target executables cannot be known ahead of time or statically declared in `runtimeInputs`.

---

## Registering a New Script

1. Create `modules/shell-scripts/<script-name>.nix`.
2. Import it in `modules/shell-scripts/default.nix` under the `scripts` set to automatically expose it in `environment.systemPackages`.
3. Run `nrs` to build and link the script into your system profile.
