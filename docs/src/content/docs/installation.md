---
title: System Installation Guide
description: Bootstrapping new machines using automated installation scripts and declarative Disko schemes.
---

This guide covers bootstrapping a new machine using the automated installation scripts and declarative [Disko](https://github.com/nix-community/disko) disk partition schemes.

---

## Prerequisites

1. Boot into a **NixOS Live USB** environment.
2. Ensure you have an active network connection (Wi-Fi or Ethernet).
3. Clone the repository and navigate into it:
   ```bash
   git clone https://gitlab.com/kylekwong/nix-config.git
   cd nix-config
   ```

### Secure Boot & LUKS Preparation
If you intend to use LUKS (Full Disk Encryption) and Lanzaboote Secure Boot:
1. Boot into your machine's firmware (BIOS) setup before installing.
2. Put Secure Boot into **Setup Mode** by clearing existing platform keys:
   - Example on Framework 16: `Administer Secure Boot` → `Erase all Secure Boot Settings`.
3. Save changes and boot back into the NixOS Live USB.

---

## Running the Automated Installer

The root [`install.sh`](https://gitlab.com/kylekwong/nix-config/-/blob/main/install.sh) script handles disk wiping, Disko partitioning, filesystem formatting, generating baseline hardware configuration, and initiating the initial NixOS system closure build.

```bash
sudo ./install.sh "<host_name>" "<user_password>" ["<luks_password>"]
```

### Parameters:
- `<host_name>`: The target host defined in `outputs.nix` and `hosts/<host_name>/` (e.g. `framework16`, `mini-pc-k8`).
- `<user_password>`: The initial login password for the primary user.
- `[<luks_password>]`: *(Optional)* The passphrase for the LUKS encrypted container (required for hosts with disk encryption like `framework16`).

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
*(This file will be automatically populated with detected kernel modules and drivers by `install.sh` during installation).*

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
