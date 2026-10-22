# Custom Installer ISO (`hosts/installer/`)

This directory defines a lightweight, reproducible NixOS installer ISO image pre-configured for automated fleet provisioning and headless remote installation over your local network.

---

## Highlights

- **mDNS Hostname Resolution**: Advertises itself as `installer.local` via Avahi. No need to scan for IP addresses on your router or type `ip a` on the target machine.
- **Pre-baked SSH Keys**: Workstation public keys from [`secrets/keys.nix`](../../secrets/keys.nix) are embedded directly into `root` and `nixos` user accounts, enabling instant passwordless SSH.
- **Pre-embedded Repository**: The full `nix-config` repository snapshot is pre-provisioned at `~/nix-config` as an initialized, writable Git repository. No need to run `git clone` before running `install.sh`.
- **Embedded Tooling**: Pre-bundles Disko, Git, Neovim, Tmux, 7-Zip, Parted, and cURL.
- **Generic & Hardware-Agnostic**: Minimal CLI environment without desktop overhead or hardware-specific display quirks.

---

## Quick Reference

### 1. Obtain the ISO Image

- **Download Pre-built (GitHub Release)**: Download the latest generated ISO directly from the rolling **[GitHub Release (installer)](https://github.com/kylekwong/nix-config/releases/tag/installer)**.
- **Or Build Locally**:
  ```bash
  nix build .#nixosConfigurations.installer.config.system.build.isoImage
  ```
  The generated hybrid UEFI/BIOS ISO will be located at `result/iso/nixos-minimal-*.iso`.

### 2. Flash to USB Drive
```bash
# Identify target USB block device (e.g. /dev/sdX)
lsblk

# Flash ISO directly (or copy to a Ventoy drive)
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

### 3. Connect & Install Remotely
Boot the target machine from the USB drive. Once booted, SSH into it from your workstation and run `install.sh` headlessly:

```bash
# Connect passwordless over LAN
ssh -o StrictHostKeyChecking=accept-new root@installer.local

# Pull latest commits and run the installer directly
cd ~/nix-config
git pull
sudo ./install.sh "<host_name>" "<user_password>" ["<luks_password>"]
```

---

## Documentation

For full provisioning instructions, declarative Disko schemes, and remote deployment recipes, refer to the online guide:

📖 **[System Installation Guide](https://nix.kyle-kwong.com/installation/)**
