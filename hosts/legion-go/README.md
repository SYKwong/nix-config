# Lenovo Legion Go (`hosts/legion-go/`)

This directory contains the machine configuration and storage definitions for the **Lenovo Legion Go** (8APU1) handheld gaming PC.

---

## Hardware Profile & Specifications

| Component | Specification | Notes |
| :--- | :--- | :--- |
| **APU** | AMD Ryzen Z1 Extreme (Phoenix, 8C/16T, Zen 4, 30W TDP max) | Integrated Radeon 780M (12 CUs RDNA3) |
| **RAM** | 16 GB LPDDR5X-7500 (Soldered, shared VRAM) | 6 GB allocated to VRAM in BIOS recommended |
| **Internal Display** | 8.8" IPS, 2560x1600 (QHD+), 144Hz, 16:10 | Native portrait scanout (`1600x2560`); rotated via kernel & Gamescope |
| **Controllers** | Detachable TrueStrike controllers, optical trackpad, gyro | Managed by Handheld Daemon (`hhd`) |
| **Storage** | 512GB / 1TB / 2TB M.2 2242 NVMe SSD (`/dev/nvme0n1`) | Unencrypted Btrfs with 20 GB hibernation swapfile |
| **Power & Sleep** | 49.2 Wh battery, 65W USB-C PD | S2idle sleep transitioning to Btrfs hibernation after 1 hour |

---

## Storage & Partitioning (`disko.nix`)

The Legion Go uses an **unencrypted Btrfs** layout partitioned via Disko:

```text
/dev/nvme0n1 (GPT)
├── Partition 1: ESP (2 GB, vfat, /boot, umask=0077)
└── Partition 2: root (100%, Btrfs with zstd compression, noatime)
    ├── Subvolume /root -> /
    ├── Subvolume /home -> /home
    ├── Subvolume /nix  -> /nix
    └── Subvolume /swap -> /.swap (20 GB swapfile for 16 GB RAM hibernation + paging)
```

### Why Unencrypted?
A handheld console has no physical keyboard attached during boot. Unencrypted Btrfs eliminates early-boot LUKS passphrase entry friction and saves APU power budget by avoiding dm-crypt AES context-switching overhead.

---

## Provisioning & Installation

Since installing an OS on the Legion Go requires accessing the BIOS first (to configure UMA frame buffer / VRAM and select the boot device), a physical keyboard is already connected via a USB-C hub/dock. Installation is therefore performed directly from the standard official NixOS Live USB.

### Step 1: BIOS Configuration
1. Connect a USB-C hub/dock with the flashed NixOS Live USB, a keyboard, and Ethernet.
2. Power on holding `Volume Up` + `Power` (or press `F2`) to enter BIOS setup.
3. Recommended settings:
   * **Configuration -> UMA Frame Buffer Size**: Set to **6G** (allocates 6 GB of shared LPDDR5X RAM to the Radeon 780M GPU).
   * **Security -> Secure Boot**: Disabled.
4. Save, exit, and select the NixOS Live USB in the boot menu.

### Step 2: Choose Your Installation Method

#### Method A: Remote LAN Deployment via `nixos-anywhere` (Recommended)
This method pushes pre-cached binaries from your workstation across your local network in ~90 seconds and writes the generated hardware configuration directly back to your workstation repo:

1. **On the Legion Go (Standard Live ISO)**:
   Ensure the network cable is connected, set a temporary root password, and check the IP:
   ```bash
   sudo passwd root
   ip a
   ```
2. **On your workstation (`mini-pc-k8` or `framework16`)**:
   Pre-cache the closure in the background to avoid internet download delays:
   ```bash
   nix build .#nixosConfigurations.legion-go.config.system.build.toplevel
   ```
   Execute `nixos-anywhere`:
   ```bash
   nix run github:nix-community/nixos-anywhere -- \
     --generate-hardware-config nixos-generate-config ./hosts/legion-go/hardware-configuration.nix \
     --flake .#legion-go \
     root@<legion-go-ip>
   ```
   `nixos-anywhere` partitions `/dev/nvme0n1` via Disko, transfers the closure across your local LAN at 100+ MB/s, installs `systemd-boot`, and reboots into Steam Big Picture.
3. **Commit the generated hardware configuration on your workstation**:
   ```bash
   git add hosts/legion-go/hardware-configuration.nix
   git commit -m "feat(legion-go): add generated hardware configuration"
   ```

---

#### Method B: Local Live USB Installation (`install.sh`)
If you prefer running the installation directly on the handheld console:

```bash
git clone https://gitlab.com/kylekwong/nix-config
cd nix-config
sudo ./install.sh "legion-go" "<user_password>"
```

1. `install.sh` detects the stub in `hosts/legion-go/hardware-configuration.nix` and automatically runs `nixos-generate-config --no-filesystems`.
2. Partitions `/dev/nvme0n1` using `hosts/legion-go/disko.nix` (unencrypted Btrfs with a 20 GB swapfile for hibernation).
3. Installs the NixOS system closure with the `legion-go-kyle` user account.
4. Reboots into the installed system.

---

## Post-Installation Setup

Once the machine boots into NixOS for the first time:

1. **Service Authentication & Setup**:
   Open a terminal (in Desktop Mode) or SSH into the device from your workstation:
   ```bash
   ./post-install.sh --auth
   ```
2. **Authorize Machine for Secrets (Agenix)**:
   Extract the machine's SSH host key and add it to `secrets/keys.nix` on your primary machine:
   ```bash
   ssh root@legion-go.local "cat /etc/ssh/ssh_host_ed25519_key.pub"
   ```
   Rekey secrets:
   ```bash
   agenix --rekey
   ```

---

## Day-2 Operations: Remote Peer Deployment (`deploy`)

To avoid typing rebuild commands on the handheld, use the remote `deploy` script from any machine on your local network:

```bash
# Build locally on workstation and activate live on Legion Go
deploy legion-go

# Or stage for next reboot
deploy legion-go boot
```

Hosts resolve automatically via mDNS (`legion-go.local`).

---

## BIOS & Firmware Updates

Lenovo Legion Go supports standard LVFS updates via `fwupdmgr` (see [Framework 16 & Supported Devices](https://nix.kyle-kwong.com/bios-update/#framework-16--supported-devices-fwupd)), as well as offline installation of Windows BIOS `.exe` packages via `fwupdtool`:

📖 **[Lenovo Legion Go BIOS Update Guide](https://nix.kyle-kwong.com/bios-update/#lenovo-legion-go-manual-capsule-via-fwupdtool)**
