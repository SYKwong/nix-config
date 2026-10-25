# Lenovo Legion Go (`hosts/legion-go/`)

This directory contains host-specific configurations for the **Lenovo Legion Go** (8APU1) handheld gaming PC.

---

## File Taxonomy

| File | Purpose |
| :--- | :--- |
| [`default.nix`](./default.nix) | Entry point importing `disko.nix`, `hardware-configuration.nix`, and `config.nix`. |
| [`config.nix`](./config.nix) | Early kernel boot parameters for display rotation (`video=eDP-1...`), custom options, and SSH host configuration. |
| [`disko.nix`](./disko.nix) | Unencrypted Btrfs storage layout with 20 GB hibernation swapfile. |
| [`hardware-configuration.nix`](./hardware-configuration.nix) | Hardware scan generated during installation. |

---

## Quick Reference Commands

### Remote Deployment from Workstation
```bash
# Build and activate live on Legion Go over mDNS
deploy legion-go

# Or stage for next reboot
deploy legion-go boot
```

### Installation
Provision via `nixos-anywhere` from a workstation or locally via the custom installer ISO:
```bash
# On installer ISO (installer.local)
install-nixos legion-go "<user_password>"
```

---

## Documentation & Deep-Dive

For complete hardware specifications, dual-session architecture (Steam Gamescope + KDE Plasma 6), Handheld Daemon (`hhd`) controls, and firmware updates, see the online documentation:

📖 **[Lenovo Legion Go Host Documentation](https://nix.kyle-kwong.com/hosts/#handheld-gaming-legion-go)**
📖 **[Lenovo Legion Go BIOS Update Guide](https://nix.kyle-kwong.com/bios-update/#lenovo-legion-go-manual-capsule-via-fwupdtool)**
