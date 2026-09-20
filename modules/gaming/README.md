# Gaming & Gamescope (`modules/gaming/`)

This directory provisions system-level gaming infrastructure across the fleet, including Valve's Steam client, Gamescope micro-compositor, GameMode daemon, Proton compatibility tools, and controller udev rules.

---

## Architecture Overview

```
modules/gaming/
├── default.nix                 # Centralized gaming stack definition
└── README.md                   # Architecture, Gamescope guide, and launch recipes
```

Gaming configuration is declared in [`modules/gaming/default.nix`](./default.nix) and imported across all hosts via [`outputs.nix`](../../outputs.nix):

1. **Steam**: Installed with local network game transfer firewall ports opened, Protontricks enabled, and pre-bundled **`proton-ge-bin`** compatibility tools registered via `programs.steam.extraCompatPackages`.
2. **Gamescope**: System-wide micro-compositor enabled with Wayland WSI support (`programs.gamescope.enableWsi = true`).
3. **GameMode**: Feral Interactive GameMode daemon configured to pause background maintenance tasks (e.g. `nixos-cache-warm.service`) during active gameplay.
4. **Game Devices Udev Rules**: Controller and joystick udev rules (`game-devices-udev-rules`) providing non-root access to DualSense, Xbox, Switch, and handheld controllers.

---

## Gamescope Architecture

[Gamescope](https://github.com/ValveSoftware/gamescope) is Valve's Wayland micro-compositor. It isolates games inside their own virtual display server, intercepting their input and rendering before outputting a composited Wayland surface to the underlying display server.

In this repository, Gamescope operates in two distinct roles depending on host form factor:

### 1. Handheld Appliance Session (`legion-go`)
* **Role**: Primary display server and desktop compositor for the entire machine.
* **Mechanism**: Activated via `programs.steam.gamescopeSession.enable = true` in [`modules/profiles/gaming-handheld/session.nix`](../profiles/gaming-handheld/session.nix).
* **Display Management**: SDDM autologins directly into the `steam` gamescope session on boot.
* **Hardware Adaptation**: Panel rotation, physical resolution (`2560x1600`), and refresh rate (`144Hz`) are declared once at the system level in [`hosts/legion-go/config.nix`](../../hosts/legion-go/config.nix).
* **Behavior**: **Every game launched on the handheld runs inside Gamescope automatically.** Zero per-game launch flags are required.

### 2. Desktop & Laptop Micro-Compositor (`framework16`, `mini-pc-k8`)
* **Role**: On-demand, nested client window inside Hyprland.
* **Mechanism**: Invoked per-game through Steam launch options.
* **Behavior**: Games run directly under Hyprland by default (leveraging Hyprland's direct scanout for zero latency). Gamescope is opted into only when a game requires resolution sandboxing, upscaling, or display virtualization.

---

## Why Gamescope Is Not Default on Desktops

While Gamescope is the default session on the Legion Go handheld, it is intentionally **not** enabled as the default launcher for desktop/laptop sessions:

1. **Display & Geometry Mismatches**: Desktops and laptops run varied displays (e.g. 16:10 2560x1600 on Framework 16 vs 16:9 4K or 1440p on external monitors). Hardcoding a global resolution breaks multi-monitor and docking workflows.
2. **Third-Party Launchers**: Games with multi-window pre-launchers (EA App, Ubisoft Connect, Paradox, Larian Launcher) often hang, render blank windows, or fail to gain focus in a nested Gamescope container.
3. **Hyprland Direct Scanout**: Hyprland already performs direct scanout for fullscreen windows (Wayland and XWayland), sending frames directly to the display controller without compositor composition latency.
4. **Cursor Trapping**: Gamescope confines the cursor to its virtual boundary, complicating multi-monitor navigation and desktop workspace switching.

---

## Gamescope Launch Recipes (Steam Launch Options)

To run a specific game inside Gamescope on a desktop or laptop, right-click the game in Steam, open **Properties → General → Launch Options**, and use one of the recipes below:

### 1. Standard Windowed Fullscreen
Renders the game at 1080p and displays it borderless fullscreen at your monitor's refresh rate:
```bash
gamescope -W 1920 -H 1080 -f -r 144 -- %command%
```

### 2. AMD FSR Upscaling (Performance Boost)
Renders the game internally at 720p and upscales to 1080p using AMD FidelityFX Super Resolution (FSR):
```bash
gamescope -w 1280 -h 720 -W 1920 -H 1080 -F fsr -f -- %command%
```
*(Adjust sharpness in-game or via `--fsr-sharpness <0-20>`, default is 2).*

### 3. Pixel-Perfect Integer Scaling (Retro & Pixel Art)
Forces integer scaling without blur or bilinear filtering for low-resolution or retro titles:
```bash
gamescope -w 640 -h 480 -W 1920 -H 1080 -S integer -f -- %command%
```

### 4. Frame Rate Limiting & Latency Tuning
Caps rendering rate at 60 FPS with low-latency presentation:
```bash
gamescope -W 1920 -H 1080 -r 60 --limiter-spatial -f -- %command%
```

### 5. High Dynamic Range (HDR)
Enables HDR mastering and wide color gamut output on supported OLED/HDR monitors:
```bash
gamescope --hdr-enabled --hdr-debug-force-output -W 2560 -H 1440 -f -- %command%
```

---

## Gamescope Command-Line Reference

| Flag | Argument | Description |
| :--- | :--- | :--- |
| **`-w`, `-h`** | `<width>`, `<height>` | Internal game render resolution (what the game sees). |
| **`-W`, `-H`** | `<width>`, `<height>` | Output window/display resolution (target display size). |
| **`-r`** | `<hz>` | Target display refresh rate (e.g. `60`, `120`, `144`). |
| **`-f`** | *None* | Fullscreen mode. |
| **`-b`** | *None* | Borderless windowed mode. |
| **`-F`** | `fsr`, `nis`, `linear`, `nearest` | Upscaling filter algorithm. |
| **`-S`** | `integer`, `fit`, `fill`, `stretch` | Scaling mode for aspect ratio handling. |
| **`--force-grab-cursor`** | *None* | Confine cursor to Gamescope window. |
| **`--cursor <path>`** | `<file>` | Custom cursor path. |
| **`--hdr-enabled`** | *None* | Enable HDR metadata and compositing. |

---

## Native Wayland vs. Gamescope Comparison

| Feature | Direct Hyprland (Default) | Native Wayland (`PROTON_ENABLE_WAYLAND=1`) | Gamescope (`gamescope --`) |
| :--- | :--- | :--- | :--- |
| **Driver** | XWayland / Native Wayland | Wine `winewayland.drv` | Gamescope internal Xwayland / Wayland |
| **Steam Overlay** | Functional | Broken | Functional |
| **Steam Input / Menus** | Functional | Inconsistent | Functional |
| **FSR / Integer Upscaling** | Game-dependent | Game-dependent | Built-in hardware scaling |
| **Latency** | Direct Scanout (Lowest) | Native (Lowest) | Minimal (~1 frame overhead) |
| **Multi-window Launchers** | Functional | Functional | Prone to focus/rendering bugs |
| **Best For** | Modern Steam titles | Benchmark latency / testing | Retro games, broken resolution pickers, FSR |
