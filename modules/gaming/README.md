# Gaming & Gamescope (`modules/gaming/`)

This directory provisions system-level gaming infrastructure across the fleet, including Valve's Steam client, Gamescope micro-compositor, GameMode daemon, Proton compatibility tools, and controller udev rules.

---

## Directory Taxonomy

```text
modules/gaming/
├── default.nix                 # Centralized gaming stack definition
└── README.md                   # Gaming stack overview and reference
```

---

## Architecture & Components

Configuration is declared in [`default.nix`](./default.nix) and imported across all hosts via [`outputs.nix`](../../outputs.nix):

1. **Steam**: Installed via `programs.steam.enable = true` with local network game transfer firewall ports opened and Protontricks enabled.
2. **Proton-GE (`extraCompatPackages`)**: Pre-bundles `proton-ge-bin` directly into Steam's compatibility dropdown without requiring manual GUI downloads.
3. **Gamescope**: System-wide micro-compositor enabled with Wayland WSI support (`programs.gamescope.enableWsi = true`).
4. **GameMode**: Feral Interactive GameMode daemon for automatic CPU governor, GPU clock, and process priority optimization during active gameplay.
5. **Controller Udev Rules**: Provisions `game-devices-udev-rules` for non-root access to DualSense, Xbox, Switch, and handheld controllers.
6. **Management GUI**: Bundles `protonup-qt` for installing and managing custom Proton and Wine versions.

---

## Why Gamescope Is Opted-In Per Game

Games run directly under Hyprland by default to leverage direct scanout for lowest possible latency. Gamescope is not set as the default desktop launcher because:
- **Display Geometry Mismatches**: Desktops and laptops run varied aspect ratios (16:10 2560x1600 on Framework 16 vs 16:9 external displays) that break with hardcoded resolutions.
- **Third-Party Launchers**: Multi-window pre-launchers (EA App, Ubisoft Connect, Paradox) often fail to render or gain focus inside nested Gamescope containers.
- **Cursor Trapping**: Gamescope confines cursor navigation, complicating multi-monitor workflows.

---

## Steam Launch Options Cheat Sheet

To run a game inside Gamescope, open the game's **Properties → General → Launch Options** in Steam:

| Use Case | Launch Option Command |
| :--- | :--- |
| **Standard Fullscreen** | `gamescope -W 1920 -H 1080 -f -r 144 -- %command%` |
| **AMD FSR Upscaling** | `gamescope -w 1280 -h 720 -W 1920 -H 1080 -F fsr -f -- %command%` |
| **Integer Scaling (Retro)** | `gamescope -w 640 -h 480 -W 1920 -H 1080 -S integer -f -- %command%` |
| **60 FPS Frame Limiting** | `gamescope -W 1920 -H 1080 -r 60 --limiter-spatial -f -- %command%` |
| **HDR Output** | `gamescope --hdr-enabled --hdr-debug-force-output -W 2560 -H 1440 -f -- %command%` |

### Key CLI Flags Reference:
- `-w`, `-h`: Internal render resolution (what the game sees).
- `-W`, `-H`: Output display resolution (target window/monitor size).
- `-r`: Display refresh rate in Hz (e.g. `60`, `120`, `144`).
- `-F`: Upscaling filter (`fsr`, `linear`, `nearest`).
- `-S`: Scaling mode (`integer`, `fit`, `fill`, `stretch`).
- `-f` / `-b`: Fullscreen / Borderless windowed.

---

## Documentation

For full architectural deep-dives, latency benchmarks, and the complete Wayland vs Gamescope comparison matrix, refer to the online guide:

📖 **[Gaming & Gamescope Documentation](https://nix.kyle-kwong.com/gaming/)**
