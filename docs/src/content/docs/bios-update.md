---
title: BIOS & Firmware Updates
description: Firmware update procedures across supported machines via LVFS/fwupd, UEFI shell, and TPM2 re-enrollment.
---

This guide covers firmware update procedures across supported machines, including automated LVFS/fwupd updates (Framework 16), manual UEFI Shell flashing (GMKtec K8 Plus), and TPM2/LUKS re-enrollment precautions.

---

## TPM2 / LUKS Re-enrollment

Firmware updates modify cryptographic PCR measurements (specifically PCR 7 for Secure Boot state and firmware certificates). As a result, **TPM2 auto-unlock will fail on the first boot after flashing a new BIOS**.

### Pre-Update Checklist:
> [!IMPORTANT]
> **Ensure you know your disk encryption passphrase** before initiating any BIOS update. You will be prompted to manually enter your LUKS passphrase on the first boot following the update.

### Post-Update Re-enrollment Steps:
1. Boot the machine after flashing firmware and manually enter your LUKS passphrase when prompted.
2. Open a terminal and clear the stale TPM2 enrollment token:
   ```bash
   sudo systemd-cryptenroll /dev/disk/by-partlabel/disk-main-luks --wipe-slot=tpm2
   ```
3. Re-enroll the TPM2 token with the updated PCR 7 measurements:
   ```bash
   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-partlabel/disk-main-luks
   ```
4. Subsequent reboots will once again unlock autonomously via the TPM.

---

## Framework 16 & Supported Devices (`fwupd`)

Firmware management on supported machines (such as the Framework Laptop 16) is handled natively via the Linux Vendor Firmware Service (LVFS) and `fwupd`. The daemon is enabled by default across all hosts via `modules/core/fwupd.nix`.

> [!NOTE]
> Ensure the laptop is plugged into AC power and the battery has at least 30% charge before initiating a firmware update.

### 1. Refresh Remote Metadata
Fetch the latest device metadata and firmware signatures from LVFS remotes:
```bash
fwupdmgr refresh
```

### 2. Check for Available Updates
Inspect connected hardware and verify available firmware upgrades:
```bash
# View all detected update-capable devices and current firmware versions
fwupdmgr get-devices

# Query LVFS for available firmware updates
fwupdmgr get-updates
```

### 3. Apply Firmware Updates
Download and schedule the UEFI capsule updates:
```bash
fwupdmgr update
```

### 4. Reboot and Finalize
Reboot the system to execute the firmware flash during boot:
```bash
systemctl reboot
```
During POST, the UEFI capsule flashing engine will apply updates to the system BIOS, retimers, and expansion cards.

> [!IMPORTANT]
> Because `framework16` uses LUKS full disk encryption with TPM2 auto-unlock, the PCR 7 measurement changes after a firmware update. Follow the [TPM2 / LUKS Re-enrollment](#tpm2--luks-re-enrollment) procedure above on your first reboot.

---

## GMKtec NucBox K8 Plus (UEFI Shell Flashing)

Official BIOS and firmware archives for the GMKtec NucBox K8 Plus are hosted on [GMKtec's Official Google Drive](https://drive.google.com/drive/folders/1y9z5q7_VEDcMsA3cGTf5SpTqgAMwJ3Xp).

> [!WARNING]
> **Filesystem Requirement: FAT32 Only**  
> The UEFI Shell firmware driver only supports **FAT32** filesystems. Multi-boot tools like Ventoy store ISOs and files on an **exFAT** partition by default, which the UEFI Shell cannot read (`map -r` will not recognize the storage partition). Flashing files must reside on a FAT32 filesystem.

### Flashing Procedure (Using Internal `/boot` Partition)
Because the NixOS EFI System Partition (`/boot`) is already formatted as FAT32, you can flash directly from the internal SSD without needing an external USB drive:

1. Extract the downloaded firmware archive and copy the folder directly to `/boot`:
   ```bash
   sudo cp -r /path/to/AR6000-MI2_PHX_260514GMK /boot/bios-update
   ```
2. Reboot directly into the UEFI firmware interface:
   ```bash
   systemctl reboot --firmware-setup
   ```
3. In the BIOS boot selection menu, launch the **UEFI Shell**.
4. Identify the mapped internal ESP filesystem (typically `fs0:` or `fs1:` via `map -r`), navigate to the update directory, and execute the flashing script:
   ```text
   fs1:
   cd bios-update
   EfiFlash.nsh
   ```
5. Allow the flashing process to complete. The system will automatically restart.
6. Once back in NixOS, remove the temporary flashing files from the ESP:
   ```bash
   sudo rm -rf /boot/bios-update
   ```
