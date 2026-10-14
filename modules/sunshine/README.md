# Sunshine Streaming Module (`modules/sunshine/`)

Provides a self-hosted [Sunshine](https://github.com/LizardByte/Sunshine) game and desktop streaming server for use with [Moonlight](https://moonlight-stream.org/) clients (such as Android tablets, phones, or secondary PCs).

---

## Capabilities & Defaults

- **Systemd User Service**: Starts automatically on graphical session login (`graphical-session.target`).
- **Hardware Acceleration**: Automatically leverages GPU hardware encoding (VA-API on AMD Radeon GPUs) for low-latency, high-framerate streaming (up to 120 FPS / 4K / HDR).
- **Firewall Integration**: Automatically opens required TCP (`47984, 47989, 47990, 48010`) and UDP (`47998-48000, 48002, 48010`) ports.
- **Input Emulation**: Automatically provisions `uinput` rules and adds the active user to `input`, `uinput`, and `video` groups for virtual mouse, keyboard, and gamepad emulation.
- **KMS / DRM Capture**: Sets `cap_sys_admin+p` on the Sunshine binary for direct frame capture capabilities.

---

## Configuration

The module is included in common system modules and **enabled by default** across hosts.

To disable on a specific device, set in [`hosts/<hostname>/config.nix`](../../hosts/):

```nix
custom.sunshine.enable = false;
```

---

## Initial Setup & Pairing

1. **Access Web Configuration**:
   Open [`https://localhost:47990`](https://localhost:47990) in your browser. (Accept the self-signed TLS certificate warning).
2. **Set Credentials**:
   On first launch, create an administrative username and password for Sunshine.
3. **Pair with Moonlight**:
   - Open Moonlight on your client device (e.g. Samsung tablet).
   - Tap your host machine. Moonlight will display a 4-digit PIN.
   - Enter the PIN in the Sunshine Web UI under the **PIN** tab.

---

## Zero-Touch Secondary Display (Automated Workflow)

When `custom.sunshine.tabletDisplay.enable = true` (default), the module registers an automated **Tablet Display** profile in Sunshine:

1. **Connect from Tablet**:
   - Open Moonlight on the tablet.
   - Tap **Tablet Display**.
   - Sunshine automatically calls `hypr-virtual-monitor start HEADLESS-1`, reading Moonlight's requested client resolution and framerate (`SUNSHINE_CLIENT_WIDTH`, `SUNSHINE_CLIENT_HEIGHT`, `SUNSHINE_CLIENT_FPS`) to spawn the virtual monitor in Hyprland with exact dimensions and 120Hz refresh rate.
2. **Disconnect from Tablet**:
   - Tap **Quit Session** in Moonlight (or exit the app) to trigger immediate cleanup.
   - **Automated Idle Watchdog (15-Minute Timeout)**: Started on-demand via `prep-cmd` only when a stream begins. If the tablet screen is locked, sleeps, or unplugs without an explicit quit, the `sunshine-watchdog` service detects the paused stream and automatically terminates `HEADLESS-1` and resets Sunshine after 15 minutes (`tabletDisplay.idleTimeout = 900`). All open workspaces safely migrate back to your primary monitor. Zero background overhead when not streaming.

You never need to touch the PC or run manual commands.

---

## Manual Virtual Monitor CLI (`hypr-virtual-monitor`)

You can also control the virtual display manually via CLI if desired:

```bash
# Toggle headless monitor
hypr-virtual-monitor toggle

# Explicit start / stop
hypr-virtual-monitor start HEADLESS-1
hypr-virtual-monitor stop HEADLESS-1
```

---

## USB Tethering (Zero-Network / Offline Mode)

To stream with zero latency (<1ms), eliminate Wi-Fi jitter, and work completely without a local network/router:

1. **Connect USB-C Cable**: Connect the tablet directly to the PC via a USB cable.
2. **Enable USB Tethering on Tablet**
3. **Connect via Moonlight**:
   - In Moonlight on the tablet, tap **`+` (Add Host)**.
   - Enter your PC's USB tethered IP (or hostname `mini-pc-k8.local`). Android DHCP assigns the PC an address on the `192.168.42.x` subnet.
   - Tap **Tablet Display** to stream directly across the physical USB bus.
   - *Note*: NetworkManager automatically marks the USB interface as `never-default`, preventing the tablet from overriding your PC's primary internet connection.
