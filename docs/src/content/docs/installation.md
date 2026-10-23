---
title: System Installation Guide
description: Bootstrapping new machines using the custom installer ISO, automated installation scripts, and declarative Disko schemes.
---

This guide covers bootstrapping a new machine using the automated installation scripts and declarative [Disko](https://github.com/nix-community/disko) disk partition schemes.

---

> [!NOTE]
> Planning to adopt or fork this configuration for your own hardware? Follow the [Adoption & Forking Guide](/adoption/) first.

## 1. Baseline: Custom Fleet Installer ISO

The baseline installation workflow uses the repository's custom NixOS installer ISO ([`hosts/installer`](https://gitlab.com/kylekwong/nix-config/-/tree/main/hosts/installer)), designed for headless, automated network provisioning:
- **Zero-Config mDNS (`installer.local`)**: Automatically advertises on the local network via Avahi. SSH into the target machine immediately without looking up IP addresses or connecting a display.
- **Pre-baked SSH Public Keys**: Authorizes workstation keys from [`secrets/keys.nix`](https://gitlab.com/kylekwong/nix-config/-/blob/main/secrets/keys.nix) into `root` and `nixos` accounts for instant passwordless SSH login.
- **Pre-embedded Repository**: The full `nix-config` repository snapshot is pre-provisioned at `~/nix-config` as an initialized, writable Git repository, eliminating manual cloning.
- **Bundled Provisioning Tooling**: Pre-installs Disko, Git, Neovim, Tmux, 7-Zip, Parted, and cURL.

### Step 1: Obtain and Flash the ISO

Choose one of two methods to get the installer image:

- **Download Pre-built (Recommended)**: Download the latest generated hybrid ISO directly from the rolling **[GitHub Release (`installer`)](https://github.com/SYKwong/nix-config/releases/tag/installer)**.
- **Or Build Locally**:
  ```bash
  # Build hybrid UEFI/BIOS ISO on any workstation running Nix (~60s):
  nix build .#nixosConfigurations.installer.config.system.build.isoImage
  ```

Flash the ISO (`result/iso/*.iso` or the downloaded release asset) to a USB drive:
```bash
# Identify target USB block device (e.g. /dev/sdX)
lsblk

# Flash ISO directly (or copy to a Ventoy drive)
sudo dd if=path/to/nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

### Step 2: Firmware & Secure Boot Setup

If installing on a host configured for LUKS (Full Disk Encryption) and Lanzaboote Secure Boot (such as `framework16`):
1. Boot into the machine's BIOS / UEFI firmware settings before installing.
2. Put Secure Boot into **Setup Mode** by clearing existing platform keys:
   - Example on Framework 16: `Administer Secure Boot` → `Erase all Secure Boot Settings`.
3. Save changes and boot the machine from the custom installer USB.

### Step 3: Connect & Launch Installation

Once the target machine boots from the installer USB:

1. **Connect Headlessly from your Workstation**:
   ```bash
   # Connect passwordless over LAN (bypasses ephemeral host key prompts)
   ssh -o StrictHostKeyChecking=accept-new root@installer.local
   ```
   *(Alternatively, log in directly at the physical console; `root` and `nixos` accounts are pre-configured with passwordless access).*

2. **Run the Installer**:
   ```bash
   # Run directly from anywhere in the live environment:
   sudo install-nixos "<host_name>" "<user_password>" ["<luks_password>"]
   ```

---

## 2. Fallback: Standard NixOS Live Media

If bootstrapping a machine using the official generic NixOS minimal installation image rather than the custom fleet ISO:

1. Boot into the official NixOS Live USB.
2. Connect to the network:
   - **Ethernet**: Automatic via DHCP.
   - **Wi-Fi**: Connect using NetworkManager (`nmcli dev wifi connect <SSID> password <PASSWORD>`) or `wpa_supplicant`.
3. Clone the repository:
   ```bash
   git clone https://gitlab.com/kylekwong/nix-config.git ~/nix-config
   cd ~/nix-config
   ```
4. Run the installer:
   ```bash
   sudo nix run .#install-nixos -- "<host_name>" "<user_password>" ["<luks_password>"]
   ```

---

## 3. Automated Installer Mechanics (`install-nixos`)

The declarative [`install-nixos`](https://gitlab.com/kylekwong/nix-config/-/blob/main/hosts/installer/install-nixos.nix) package (pre-installed on the custom ISO and available via `nix run .#install-nixos`) handles disk wiping, Disko partitioning, filesystem formatting, generating baseline hardware configuration, and initiating the initial NixOS system closure build.

```bash
# On custom installer ISO:
sudo install-nixos "<host_name>" "<user_password>" ["<luks_password>"]

# On standard live media:
sudo nix run .#install-nixos -- "<host_name>" "<user_password>" ["<luks_password>"]
```

> [!NOTE]
> **Dual Execution Architecture**:
> - **Pre-installed on Custom ISO**: On the repository's custom installer ISO, `install-nixos` is pre-baked into `environment.systemPackages` (via [`hosts/installer/default.nix`](https://gitlab.com/kylekwong/nix-config/-/blob/main/hosts/installer/default.nix)), allowing zero-build execution directly from `$PATH`.
> - **Flake `apps` for Generic Live Media**: [`hosts/installer/outputs.nix`](https://gitlab.com/kylekwong/nix-config/-/blob/main/hosts/installer/outputs.nix) exports `install-nixos` as flake `packages` and `apps` (`.#install-nixos`, `.#default`). This allows running the installer on any official generic NixOS live USB via `nix run .#install-nixos` without compiling the custom ISO image.
> - **Why `post-install` differs**: Unlike `install-nixos`, onboarding tools like `post-install` only execute *after* a host is installed and booted into its own system closure, so they reside strictly in `modules/shell-scripts/` without redundant flake app boilerplate.

### Script Arguments

| Parameter | Required | Description |
| :--- | :---: | :--- |
| `<host_name>` | **Yes** | Target host defined in `outputs.nix` and `hosts/<host_name>/` (e.g. `framework16`, `mini-pc-k8`). |
| `<user_password>` | **Yes** | Initial login password for the primary user account. |
| `[<luks_password>]` | **Conditional** | Passphrase for the LUKS encrypted container (required for hosts with disk encryption like `framework16`). |

Once the installation finishes, the script automatically triggers a system reboot.

---

## Disk Layouts & Disko Schemes

Target drives are strictly referenced using persistent `/dev/disk/by-id/...` paths rather than volatile device nodes like `/dev/nvme0n1` or `/dev/sda`.

### Current Fleet Partitions:

| Host Name | Purpose | LUKS + Secure Boot | Hibernation Support | File System | Swap File Size |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **`framework16`** | Workstation Laptop | **YES** | **YES** | Btrfs (zstd compressed) | 100GB swapfile (hibernation) |
| **`mini-pc-k8`** | Living Room HTPC | **NO** | **NO** | Btrfs (zstd compressed) | 8GB swap |

Each host declares its partition scheme in `hosts/<host_name>/disko.nix`. Disko creates standard Btrfs subvolumes:
- `/@root` → `/`
- `/@home` → `/home`
- `/@nix` → `/nix`
- `/@swap` → `/.swapvol` (`framework16`) or `/.swap` (`mini-pc-k8`)

> [!TIP]
> **Hibernation Swap Sizing**: For hosts configured with hibernation support (such as `framework16`), size the swap partition or swapfile to **RAM capacity + 2 to 4GB** (e.g. 96GB RAM → 100GB swap) in `disko.nix` to ensure sufficient capacity for system memory images.

> [!NOTE]
> **Framework Laptop 16 Hardware Configuration**: For Framework Laptop 16 systems with AMD Ryzen 7040 series without an expansion bay graphics module, the repository's baseline [`hosts/framework16/hardware-configuration.nix`](https://gitlab.com/kylekwong/nix-config/-/blob/main/hosts/framework16/hardware-configuration.nix) can be referenced directly as a known-good template without re-probing.

---

## Adding a New Machine

To prepare a new host before running the installer:

### Step 1: Declare the Host in `outputs.nix`
Open `outputs.nix` and add an entry under the `hosts` attribute set:

```nix
<host_name> = {
  username = "<user_name>";

  extraModules = [
    # Host-specific modules (e.g. hardware packages, laptop power, desktop)
  ];
};
```

### Step 2: Create the Host Directory
```bash
mkdir -p ./hosts/<host_name>
```

### Step 3: Define Partition Scheme (`disko.nix`)
Create `./hosts/<host_name>/disko.nix` defining your GPT partitions, EFI system partition (`/boot`), swap, and filesystems using persistent disk IDs (`/dev/disk/by-id/...`).

### Step 4: Create Stub Hardware Configuration
Create an empty stub file at `./hosts/<host_name>/hardware-configuration.nix`:
```nix
{

}
```
*(This file will be automatically populated with detected kernel modules and drivers by `install-nixos` during installation).*

### Step 5: Create Host Entrypoint (`default.nix`)
Create `./hosts/<host_name>/default.nix`:
```nix
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    # ./config.nix # (Optional: host-specific module options / secrets)
  ];
}
```

---

## Next Steps

After the installer completes and the system reboots into your new NixOS installation, proceed directly to the [Post-Installation Setup](/post-installation/) guide to enroll TPM2 auto-unlock, register SSH keys, and configure agenix secrets.
