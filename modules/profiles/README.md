# System Profiles (`modules/profiles/`)

This directory contains form-factor and device-type system profiles. Profiles compose reusable NixOS system modules to define the high-level operating persona of a machine (`desktop`, `laptop`, `gaming-handheld`).

---

## Profile Taxonomy

| Profile | Target Form Factor | Characteristics & Included Modules |
| :--- | :--- | :--- |
| **[`desktop/`](./desktop)** | Fixed workstations & HTPCs (`mini-pc-k8`) | Persistent wired/wireless networking, static CIFS NAS automounts (`fileSystems.<mount>`), power-profiles-daemon. |
| **[`laptop/`](./laptop)** | Portable clamshell notebooks (`framework16`) | Lid switch handling, dynamic NAS reachability daemon (`check-nas-cifs`), power-profiles-daemon, `suspend-then-hibernate`. |
| **[`gaming-handheld/`](./gaming-handheld)** | Handheld PC gaming consoles (`legion-go`) | SteamOS-style dual-session environment (Steam Gamescope + KDE Plasma 6), Handheld Daemon (`hhd`), first-boot desktop autologin, Catppuccin SDDM greeter with on-screen keyboard, `suspend-then-hibernate`. |

---

## Profile Deep-Dives

### 1. Gaming Handheld (`modules/profiles/gaming-handheld/`)

Mimicking the SteamOS and Bazzite-deck paradigm, the handheld profile provisions a console-first experience with a fully functional desktop environment available on demand.

#### A. Dual-Session Architecture
1. **Gaming Mode (Default Session)**:
   - Powered by `programs.steam.gamescopeSession` managed under SDDM (Wayland).
   - Boots directly into Steam Big Picture mode with native controller navigation, Gamescope compositing and display scaling, and Polkit rules allowing in-game Wi-Fi configuration.
2. **Desktop Mode (On-Demand)**:
   - Full **KDE Plasma 6 (Wayland)** environment for file management, browser navigation, and terminal access.
   - Includes touch-friendly UI sizing and on-screen virtual keyboard (`qtvirtualkeyboard`).

#### B. Mode Switching Workflow (SteamOS Style)
Session transitions avoid login greeter prompts and require zero physical keyboard input:
* **Switch to Desktop**:
  - Selecting "Switch to Desktop" from Steam Big Picture invokes `steamos-session-select plasma`.
  - The script writes a temporary drop-in override to `/etc/sddm.conf.d/zz-steamos-autologin.conf` (`Session=plasma.desktop`) and terminates the user session via `loginctl terminate-user`.
  - SDDM immediately reloads and autologins into KDE Plasma 6 without requiring a password.
* **Return to Gaming Mode**:
  - A desktop shortcut `Return to Gaming Mode` (`~/Desktop/Return.desktop`) and application launcher entry invokes `steamos-session-select gamescope`.
  - The script removes `/etc/sddm.conf.d/zz-steamos-autologin.conf` and terminates the user session.
  - SDDM reloads and launches back into Steam Big Picture.

#### C. First-Boot Initialization Sentinel
To ensure initial provisioning, Wi-Fi configuration, and post-installation setup (`./post-install.sh`) can be performed comfortably:
- `display-manager.serviceConfig.ExecStartPre` inspects `/var/lib/handheld-first-boot-done`.
- **First Boot**: If the sentinel file is absent, it writes the Plasma override drop-in and creates the sentinel file. The machine automatically boots directly into KDE Plasma 6 for first-run onboarding.
- **Subsequent Boots**: If the sentinel file is present, any temporary session override is automatically removed upon reboot, guaranteeing the console defaults back to Steam Gaming Mode.
- **Reset**: Removing `/var/lib/handheld-first-boot-done` re-triggers the first-boot desktop behavior.

#### D. SDDM Theming & Virtual Keyboard
- Greeter is themed with `catppuccin-sddm-corners` (`pkgs.catppuccin-sddm-corners`) to match the global Catppuccin Mocha aesthetic.
- Configured with `services.displayManager.sddm.settings.General.InputMethod = "qtvirtualkeyboard"` to provide an accessible on-screen keyboard toggle on touchscreen displays.

#### E. Hardware Controllers & Power Management
- **Handheld Daemon (`hhd`)**: Enabled with `adjustor.enable = true` to emulate DualSense/Xbox controllers for TrueStrike detachable controllers, map back grip buttons, expose gyro data to Steam Input, manage thumbstick RGB lighting, and regulate TDP curves.
- **Power Management**: Configured for `suspend-then-hibernate` (`services.logind.settings.Login.HandlePowerKey = "suspend-then-hibernate"`). Tapping the power button suspends to `s2idle` immediately; if left sleeping for more than 1 hour, it transitions to hibernate to save battery and eliminate heat buildup.

---

### 2. Laptop (`modules/profiles/laptop/`)

Tailored for mobile clamshell machines that transition between home dock networks and untrusted mobile connections.

* **Dynamic CIFS Reachability**:
  Because laptops disconnect from home LANs, mounting CIFS network shares statically in `fstab` can cause long blocking timeouts and system hangs during boot or network disconnects.
  - Declares the CIFS mount with `noauto` and `_netdev`.
  - Runs a periodic timer and NetworkManager dispatcher script (`check-nas-cifs`) using `nc -z -w 1` to probe the NAS at port 445.
  - Automatically mounts the filesystem when the NAS is reachable, and triggers lazy unmounting (`umount -l`) when disconnecting.
* **Lid & Sleep Handling**:
  - `HandleLidSwitch = "suspend-then-hibernate"`
  - `HibernateDelaySec = "30min"`

---

### 3. Desktop (`modules/profiles/desktop/`)

Tailored for stationary workstations and living room media PCs with stable power and wired/static home networking.

* **Static CIFS Mounts**: Direct systemd automounts with credentials managed via Agenix (`age.secrets.smb-credentials`).
* **Power & Performance**: Uses `power-profiles-daemon` with performance and balanced governors, omitting battery conservation logic.

---

## Documentation

For fleet architecture and host profile composition, refer to the online guide:

📖 **[System Profiles Documentation](https://nix.kyle-kwong.com/hosts/)**
