---
title: Custom Shell Scripts
description: Custom CLI tools and system management utilities packaged as native Nix derivations.
---

This directory (`modules/shell-scripts/`) contains custom CLI tools and system management utilities packaged as native Nix derivations and added directly to `environment.systemPackages`.

---

## Existing Scripts

| Script | Entrypoint File | Builder | Description |
| :--- | :--- | :--- | :--- |
| **`rebuild`** (alias: **`nrs`**) | `modules/shell-scripts/rebuild.nix` | `writeShellApplication` | NixOS configuration rebuild engine that formats code, stages a boot entry via `nh os boot`, activates live via `switch-to-configuration`, and checks for pending kernel reboots (with a 10s auto-skip prompt). Run via alias `nrs`. |
| **`hypr-virtual-monitor`** | `modules/shell-scripts/hypr-virtual-monitor.nix` | `writeShellApplication` | Dynamic headless virtual monitor controller and idle socket watchdog for Hyprland and Sunshine streaming (`start`, `stop`, `toggle`, `watchdog`). |
| **`display-brightness`** | `modules/shell-scripts/display-brightness.nix` | `writeShellApplication` | Display brightness manager targeting focused internal display backlight with automatic fallback to `hyprsunset` software dimming for external monitors. |
| **`update-wallpaper`** (alias: **`nwall`**) | `modules/shell-scripts/update-wallpaper.nix` | `writeShellApplication` | Automated wallpaper synchronization pipeline: pushes local wallpaper changes, updates `wallpapers` flake input, rebuilds system live (`nrs`), and submits auto-merging MR. |
| **`rofi-keybinds`** | `modules/shell-scripts/rofi-keybind.nix` | `writeShellApplication` | Dynamic cheat sheet parsed from `hyprctl binds` and displayed in an interactive Rofi dmenu (`SUPER + SHIFT + /` or `SUPER + F1`). |
| **`kb-light-manager`** | `modules/shell-scripts/kb-light-manager.nix` | `writeShellApplication` | Framework laptop keyboard backlight toggle and brightness manager using `qmk_hid`. |
| **`tui-wrap`** | `modules/shell-scripts/tui-wrap.nix` | `writeShellScriptBin` *(Exception)* | Helper to spawn arbitrary CLI and TUI tools (like Yazi or Btop) inside floating Foot terminal surfaces. Dynamically resolves user commands from runtime `PATH`. |

---

## System Rebuild Workflow (`rebuild` / `nrs`)

The system rebuild engine standardizes configuration deployment across all hosts:

1. **Formatting**: Runs `nix fmt` automatically prior to building to keep the repository formatted.
2. **Atuin Sync**: Bridges newly synced shell history into local Fish suggestions via `atuin-to-fish`.
3. **Staging & Live Activation**: Creates a new bootloader entry via `nh os boot` and activates live system changes via `switch-to-configuration switch`.
4. **Binary Cache Synchronization**: On remote hosts, synchronizes the newly built system closure back to `mini-pc-k8` over SSH if reachable.
5. **Pending Kernel Reboot Check**: Compares the running kernel (`uname -r`) against the newly staged kernel in `/nix/var/nix/profiles/system/kernel`. If a kernel update is pending, prompts the user to reboot immediately with an automatic **10-second timeout** (`read -r -t 10`) to prevent blocking unattended or automated rebuilds.

---

## Wallpaper Synchronization Workflow (`update-wallpaper` / `nwall`)

The `update-wallpaper` pipeline automates the end-to-end synchronization of private wallpapers into the NixOS configuration:

1. **Wallpaper Repo Push**: Inspects the local wallpaper repository (resolved via path priority), commits uncommitted changes (if present), and pushes `HEAD` to `origin` (`private-wallpaper.git`).
2. **Branching & Flake Update**: Branches a fresh `wallpaper-update-<timestamp>` from `origin/main` and runs `nix flake update wallpapers`. If `flake.lock` has no diff, the temporary branch is deleted and the script exits early.
3. **Local Rebuild Verification**: Executes `rebuild` (`nrs`) live on the workstation to verify that the updated wallpaper assets evaluate, build, and switch cleanly.
4. **Auto-Merge Request via Git Push Options**: Formats code with `nix fmt`, commits `flake.lock`, and pushes the branch directly to GitLab using native push options:
   ```bash
   git push -u origin "$UPDATE_BRANCH" \
     -o merge_request.create \
     -o merge_request.target=main \
     -o merge_request.title="chore(flake): update wallpapers $(date +'%Y-%m-%d')" \
     -o merge_request.description="Automated wallpaper update via update-wallpaper script." \
     -o merge_request.auto_merge \
     -o merge_request.remove_source_branch \
     -o merge_request.squash
   ```
5. **CI Bypass**: GitLab CI (`.gitlab-ci.yml`) automatically skips `verify-flake` execution on `*-update-*` branches (such as `wallpaper-update-*` and `flake-update-*`) since the configuration was already verified and switched live locally, allowing GitLab to immediately merge the MR.
6. **State Restoration**: Automatically checks out the user's starting Git branch upon completion.

### Wallpaper Repository Path Priority

The script automatically detects the local wallpaper source repository by probing for an existing `.git` directory in descending order of precedence:

| Priority | Path | Category | Rationale |
| :---: | :--- | :--- | :--- |
| **0** | `$WALLPAPER_DIR` | Environment Variable | Explicit runtime override passed by caller. |
| **1** | `~/data/private-wallpaper` | **Primary Default** | NAS CIFS share matching upstream repo name (`private-wallpaper.git`). Eliminates duplicate local disk storage. |
| **2** | `~/Pictures/[Ww]allpaper[s]` | User Media | Standard XDG Pictures directory (accepts `wallpaper`, `Wallpaper`, `wallpapers`, `Wallpapers`). |
| **3** | `~/[Ww]allpaper[s]` | Legacy Local | Home directory legacy path (accepts `Wallpaper`, `wallpaper`, `Wallpapers`, `wallpapers`) for backwards compatibility during migration. |

If none of the candidate paths contain an initialized `.git` repository, the script falls back to `~/data/private-wallpaper` and halts with a descriptive error.

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
