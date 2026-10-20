# Sunshine Streaming Module (`modules/sunshine/`)

Provides a self-hosted [Sunshine](https://github.com/LizardByte/Sunshine) game and desktop streaming server for use with [Moonlight](https://moonlight-stream.org/) clients (tablets, phones, handhelds, or secondary PCs).

---

## Directory Taxonomy

```text
modules/sunshine/
├── default.nix                 # Sunshine server service, firewall, and tabletDisplay options
└── README.md                   # Streaming module overview and developer reference
```

---

## Capabilities

- **Hardware Acceleration**: Automatically leverages GPU hardware encoding (VA-API on AMD Radeon) for low-latency streaming (up to 120 FPS / 4K / HDR).
- **Direct Wayland Capture (`wlr`)**: Uses `wlr-screencopy-unstable-v1` DMA-BUF capture directly with Hyprland, bypassing XDG Desktop Portal prompts and preventing `hyprland-share-picker` dialogs on service startup.
- **Firewall Integration**: Automatically opens required TCP (`47984, 47989, 47990, 48010`) and UDP (`47998-48000, 48002, 48010`) ports.
- **Input & Capture Permissions**: Configures `uinput` rules and grants `cap_sys_admin+p` capabilities for direct KMS/DRM display capture.
- **Automated Virtual Display**: Automatically provisions a headless display (`HEADLESS-1`) and an on-demand idle watchdog when connecting via Moonlight.

---

## Configuration Options

Declared in [`default.nix`](./default.nix) and configurable per-host in `hosts/<hostname>/config.nix`:

```nix
# Toggle Sunshine service across the host (default: true)
custom.sunshine.enable = true;

# Autostart Sunshine upon graphical session login (default: true)
custom.sunshine.autoStart = true;

# Automated tablet virtual secondary display (default: true)
custom.sunshine.tabletDisplay.enable = true;

# Idle watchdog timeout in seconds before auto-teardown (default: 900)
custom.sunshine.tabletDisplay.idleTimeout = 900;
```

---

## Quick Setup & Management

### 1. Web Management Interface (Pairing)
- **URL**: [`https://localhost:47990`](https://localhost:47990) *(accept the self-signed TLS certificate warning)*.
- **First Launch**: Create administrative username and password.
- **Client Pairing**: Tap your PC in Moonlight on your client device to generate a 4-digit PIN, then enter it in the Sunshine Web UI under the **PIN** tab.

### 2. Service Debugging & Inspection
Sunshine runs as a systemd user service attached to `graphical-session.target`:

```bash
# Check service status
systemctl --user status sunshine

# Follow live streaming and connection logs
journalctl --user -u sunshine -f

# Restart service after configuration adjustments
systemctl --user restart sunshine
```

---

## Manual Virtual Display Controls (`hypr-virtual-monitor`)

Headless monitors can be managed manually via [`hypr-virtual-monitor`](../shell-scripts/hypr-virtual-monitor.nix):

```bash
# Toggle headless monitor on/off
hypr-virtual-monitor toggle

# Explicit start or stop
hypr-virtual-monitor start HEADLESS-1
hypr-virtual-monitor stop HEADLESS-1
```

---

## USB Tethering (Zero-Latency Offline Mode)

For sub-millisecond latency (<0.5ms) without Wi-Fi jitter:
1. Connect client tablet directly to the PC via a USB-C cable.
2. Enable **USB Tethering** on the client device.
3. Moonlight connects via the PC's USB IP or hostname (`<hostname>.local`).
4. NetworkManager automatically flags the tethered interface with `ipv4.never-default = true` to preserve primary internet routing.

---

## Documentation

For full architectural diagrams, watchdog socket polling details, and Moonlight client configuration, refer to the online guide:

📖 **[Sunshine Streaming & Tablet Display Documentation](https://nix.kyle-kwong.com/sunshine/)**
