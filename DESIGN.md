# Design Document: Lenovo Legion Go Handheld Console (`legion-go`)

## 1. Overview & Objective

This document specifies the architecture, hardware enablement, and configuration design for adding the **Lenovo Legion Go** handheld gaming console as a first-class host (`legion-go`) in `nix-config`.

### Target Host Attributes
* **Host Name**: `legion-go`
* **Primary User**: `legion-go-kyle` (UID/GID dynamically assigned; member of `wheel`, `video`, `users`)
* **Architecture**: `x86_64-linux`
* **Device Form Factor**: Handheld PC Gaming Console (8.8" touchscreen, detachable TrueStrike controllers)

---

## 2. Hardware Profile & Technical Specifications

| Component | Specification | NixOS / Linux Consideration |
| :--- | :--- | :--- |
| **SoC / APU** | AMD Ryzen Z1 Extreme (8 cores, 16 threads, Zen 4, 4nm) | Handled by `common-cpu-amd` + `common-cpu-amd-pstate` |
| **Graphics** | AMD Radeon 780M (12 CUs RDNA 3, up to 2.7 GHz) | Handled by `common-gpu-amd` + Mesa Radv driver |
| **Memory** | 16 GB LPDDR5X-7500 MHz shared | System & VRAM dynamically allocated |
| **Internal Display** | 8.8" QHD+ (2560x1600), 144Hz, 16:10 IPS touchscreen | **Native portrait scanout (1600x2560)**; requires DRM & compositor 90° rotation |
| **Storage** | M.2 2242 PCIe 4.0 NVMe SSD | Fast Btrfs with zstd compression; default target `/dev/nvme0n1` |
| **Controllers** | Lenovo TrueStrike detachable controllers (hall-effect sticks, trackpad, gyro, back buttons) | Requires Handheld Daemon (`hhd`) for xpad / dualsense emulation and mapping |
| **Wireless** | Wi-Fi 6E + Bluetooth 5.2 | Wireless managed by NetworkManager/iwd; Bluetooth powered on at boot |
| **Power & TDP** | 15W–30W configurable TDP | `power-profiles-daemon` (`ppd.nix`) integrated with `hhd.adjustor` |

---

## 3. Storage & Partitioning Scheme (`hosts/legion-go/disko.nix`)

### Architectural Decision: Unencrypted Btrfs (No LUKS)
* **Design Rationale**:
  1. **Handheld Console Ergonomics**: A gaming handheld does not have a physical keyboard attached. Entering complex LUKS decryption passphrases at early boot on a virtual keyboard or external peripheral creates high friction and impedes quick-resume gaming.
  2. **Performance & Latency**: Omitting disk encryption eliminates dm-crypt context-switching overhead and CPU contention on the shared APU power budget, reserving maximal compute for game rendering.
  3. **Consistency**: Matches the unencrypted Btrfs design utilized on the living-room HTPC (`mini-pc-k8`).

### Partition Layout & Subvolumes
```
/dev/nvme0n1 (GPT)
├── Partition 1: ESP (2 GB, vfat, /boot, umask=0077)
└── Partition 2: root (100%, Btrfs with zstd compression, noatime)
    ├── Subvolume /root -> /
    ├── Subvolume /home -> /home
    ├── Subvolume /nix  -> /nix
    └── Subvolume /swap -> /.swap (20 GB swapfile for 16 GB RAM hibernation + paging)
```
* **Storage Maintenance**: Automated monthly Btrfs scrub (`services.btrfs.autoScrub`).
* **Device Target**: `lib.mkDefault "/dev/nvme0n1"`, easily retargetable to `/dev/disk/by-id/...` post-installation.

---

## 4. Hardware Enablement & Kernel Quirks (`hosts/legion-go/config.nix`)

### 4.1. Display Panel Orientation Quirk
* **Hardware Quirk**: The Legion Go panel is physically manufactured in portrait orientation (1600x2560). Upstream Linux kernel DRM quirk identifies the device (`Legion Go 8APU1`) with `lcd1600x2560_leftside_up` (`DRM_MODE_PANEL_ORIENTATION_LEFT_UP`).
* **Kernel Early Boot Configuration**:
  ```nix
  boot.kernelParams = [
    "video=eDP-1:panel_orientation=right_side_up"
    "fbcon=rotate:1"
  ];
  ```
  This ensures the initramfs, Plymouth splash, and systemd virtual console are properly rotated right-side up from the earliest boot stage.

### 4.2. Handheld Daemon (`services.handheld-daemon`)
* **Purpose**: Provides full Linux hardware enablement for the Legion Go TrueStrike controllers and thermal management:
  * Emulates a standard DualSense or Xbox 360 gamepad for Steam / Proton compatibility.
  * Maps back grip buttons (Y1, Y2, Y3, M2, M3) and optical mouse/trackpad sensor.
  * Exposes gyro data to Steam Input for motion aiming.
  * Thumbstick RGB ring customization.
  * TDP and fan curve regulation via the `adjustor` plugin and `acpi_call` kernel module.
* **NixOS Configuration**:
  ```nix
  services.handheld-daemon = {
    enable = true;
    user = username;
    adjustor.enable = true; # Enables TDP control & automatically provisions acpi_call
  };
  ```

### 4.3. Wireless & Peripheral Connectivity
* **Bluetooth**: `custom.wireless.bluetooth.powerOnBoot = true;` ensures detached TrueStrike controllers, external Bluetooth gamepads (8BitDo, DualSense, Xbox), and wireless headsets reconnect seamlessly upon boot.

### 4.4. Power Management & Hibernation (`suspend-then-hibernate`)
* **Power Key Behavior**:
  ```nix
  services.logind.settings.Login = {
    HandlePowerKey = "suspend-then-hibernate";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "1h";
  };
  ```
  Tapping the power button suspends immediately to `s2idle` for instant resume. If left idle/unattended for more than 1 hour (e.g. inside a carrying case or backpack), the system transitions to hibernation to conserve battery and eliminate heat buildup.
* **Btrfs Hibernation**: Modern systemd (v255+) and Linux 6.12+ auto-detect and resume from Btrfs swapfiles without manual `resume_offset` kernel parameters.

### 4.5. Peer-to-Peer Remote Deployment over SSH & mDNS (`deploy`)
* **Design Rationale**:
  * Typing git and rebuild commands on an 8.8" touchscreen without a physical keyboard is ergonomically painful.
  * Running background timers on a handheld with hibernation enabled introduces severe risks: if a new generation is staged in the bootloader while an older session hibernates, waking the system triggers resume mismatches (`PM: Image mismatch`) and dirty filesystem corruption.
  * In hibernation (ACPI S4), the machine is powered down and cannot receive timer-based updates anyway.
* **Architecture**:
  * **mDNS / Avahi**: All hosts (`framework16.local`, `mini-pc-k8.local`, `legion-go.local`) advertise and resolve dynamically via `services.avahi`.
  * **Root SSH Authorization**: Trusted user keys from `secrets/keys.nix` are authorized for `root`, allowing secure, passwordless remote deployments (`nixos-rebuild switch --target-host root@<host>.local`).
  * **Peer Deployment Tool (`deploy`)**: Packaged in `modules/shell-scripts/deploy.nix`, allowing any machine to build and push updates live or staged to any peer:
    ```bash
    deploy legion-go          # Build locally and activate live on Legion Go
    deploy-legion             # Convenient shell alias
    ```

---

## 5. Graphical Interface: SteamOS-Style Gaming & Desktop Modes

Mimicking SteamOS and Bazzite-deck, the gaming handheld features a dual-session architecture managed via SDDM with Wayland:

1. **Gaming Mode (Default)**: Dedicated Steam Gamescope Session booting straight into Steam Big Picture with controller navigation, gamescope display rotation/scaling, and Handheld Daemon overlay.
2. **Desktop Mode (On Demand)**: Touch-friendly **KDE Plasma 6 (Wayland)** environment with on-screen keyboard (virtual keyboard), gesture navigation, and desktop file management.

### Mode Switching Workflow (SteamOS Style)
* **Switch to Desktop**:
  * Selecting "Switch to Desktop" from the Steam Big Picture power menu invokes `steamos-session-select plasma`.
  * The helper writes a temporary autologin override to `/etc/sddm.conf.d/zz-steamos-autologin.conf` (`Session=plasma.desktop`) and terminates the session (`loginctl terminate-user "$USER"`).
  * SDDM seamlessly relaunches into KDE Plasma 6 without asking for a password.
* **Return to Gaming Mode**:
  * A desktop shortcut `Return to Gaming Mode` (`~/Desktop/Return.desktop`) and application launcher entry invokes `steamos-session-select gamescope`.
  * The helper deletes the temporary autologin override and terminates the session, prompting SDDM to reload the default `steam` session.
* **Boot Initialization & Failsafe**:
  * An `ExecStartPre` drop-in on `display-manager.service` checks for the sentinel file `/var/lib/handheld-first-boot-done`.
  * **First Boot**: If the sentinel file is absent, it automatically forces `Session=plasma.desktop` via `/etc/sddm.conf.d/zz-steamos-autologin.conf` and creates the sentinel, booting straight into KDE Plasma for initial setup (Wi-Fi, terminal, post-install scripts).
  * **Subsequent Boots**: If the sentinel file is present, any temporary session override is automatically removed upon reboot, guaranteeing the console defaults back to Steam Gaming Mode.
* **Theming & Touch Input**:
  * Themed with `catppuccin-sddm-corners` (`pkgs.catppuccin-sddm-corners`) to match the global Catppuccin Mocha palette.
  * Configured with `services.displayManager.sddm.settings.General.InputMethod = "qtvirtualkeyboard"` and `pkgs.kdePackages.qtvirtualkeyboard` for virtual on-screen keyboard support on the touchscreen.

---

## 6. Flake & Module Integration (`outputs.nix`)

* **Host Registration in `outputs.nix`**:
  ```nix
  legion-go = {
    username = "legion-go-kyle";
    system = "x86_64-linux";

    extraModules = [
      nixos-hardware.nixosModules.common-cpu-amd
      nixos-hardware.nixosModules.common-cpu-amd-pstate
      nixos-hardware.nixosModules.common-gpu-amd
      nixos-hardware.nixosModules.common-pc-ssd

      ./modules/profiles/gaming-handheld
    ];
  };
  ```
* Baseline modules automatically inherited:
  * `./modules/gaming` (Steam, Gamescope, GameMode, ProtonUp-Qt, game devices udev rules).
  * `./modules/wireless` (Wi-Fi, Bluetooth).
  * `./modules/core` (Linux latest kernel, zramSwap, pipewire, fonts).

---

## 7. Installation & Provisioning Workflow

1. **Live USB Installation**:
   ```bash
   sudo ./install.sh "legion-go" "<user_password>"
   ```
   * `install.sh` detects the stub in `hosts/legion-go/hardware-configuration.nix` and runs `nixos-generate-config --no-filesystems`.
   * Partitions the drive using `hosts/legion-go/disko.nix` without requiring a LUKS passphrase.
   * Installs NixOS system closure with `legion-go-kyle` user account.

2. **First Boot & Setup**:
   * Run `./post-install.sh` to initialize SSH host keys, user keys, and remote configurations.
   * Rekey `secrets/keys.nix` via `agenix --rekey` on an authorized machine.
