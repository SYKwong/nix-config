---
title: Welcome to nix-config
description: Declarative, multi-host NixOS and Home Manager configuration fleet.
template: splash
hero:
  tagline: Declarative multi-host NixOS and Home Manager configuration fleet managing workstations, laptops, and gaming consoles.
  actions:
    - text: System Installation
      link: /installation/
      icon: right-arrow
      variant: primary
    - text: Flake Architecture
      link: /architecture/
      icon: document
      variant: secondary
    - text: View on GitLab
      link: https://gitlab.com/kylekwong/nix-config
      icon: external
      variant: minimal
---

## Quick Navigation

| Section | Description | Key Pages |
| :--- | :--- | :--- |
| **Getting Started** | Setting up new machines from scratch | [System Installation](/installation/) • [Adoption & Forking](/adoption/) • [Post-Installation](/post-installation/) • [BIOS & Firmware](/bios-update/) |
| **Architecture** | Flake organization and machine topologies | [Flake Architecture](/architecture/) • [Split CI Architecture](/split-ci/) • [Hosts Inventory](/hosts/) • [Home Manager](/home-manager/) • [Dotfiles](/dotfiles/) |
| **Modules** | Reusable system capabilities and integrations | [System Modules](/modules/) • [Sunshine Streaming](/sunshine/) • [Gaming & Gamescope](/gaming/) • [Flatpak](/flatpak/) • [Shell Scripts](/shell-scripts/) • [Overlays](/overlays/) |
| **Operations** | Day-to-day maintenance and security | [Secrets (agenix)](/secrets/) • [Desktop Entries](/desktop-entries/) • [Code Quality](/code-quality/) |

---

## Core Pillars

1. **Centralized Flake Abstraction:**
   All physical systems are declared as attribute sets inside a unified `outputs.nix` entry point, standardizing primary users and per-host system modules.

2. **Full Disk Encryption & TPM2 Auto-Unlock:**
   Supported machines (e.g. `framework16`) leverage LUKS disk encryption integrated with TPM2 hardware PCR 7 policies via `systemd-cryptenroll` and Lanzaboote UEFI Secure Boot.

3. **Live Out-of-Store Dotfiles:**
   Fast-iterating GUI and window manager configurations (Hyprland Lua configs, Kitty sessions, Starship themes) are linked out-of-store directly to the working repository, allowing instantaneous reloads without triggering full NixOS rebuilds.

4. **Hands-off Provisioning:**
   New machines are bootstrapped using declarative installer (`install-nixos`) and onboarding (`post-install`) scripts that automatically format disks, initialize hardware configs, generate SSH keys, and configure cryptographic secrets.

---

## Quick Command Reference

### Rebuilding the System
The system includes a declarative wrapper script alias `nrs` (NixOS-Rebuild Switch):

```bash
# Format code, stage boot entry, and activate live generation
nrs
```

### Git & Commits
```bash
# Stage all changes, commit with conventional commit message, and push
git lazy "<commit message>"
```

### Code Quality & Validation
```bash
# Format and lint code (Nix, Bash, Lua, TOML via treefmt)
nix fmt

# Flake evaluation check
nix flake check
```

---

## Active Fleet Inventory

| Host | Role | Hardware | Key Technologies |
| :--- | :--- | :--- | :--- |
| **[`framework16`](/hosts/)** | Primary Workstation Laptop | Framework Laptop 16 (AMD Ryzen 7840HS, 96GB RAM) | LUKS + TPM2, Lanzaboote Secure Boot, Btrfs + Swap Hibernation |
| **[`mini-pc-k8`](/hosts/)** | HTPC / Living Room Desktop | GMKtec NucBox K8 Plus (AMD Ryzen 8845HS, 64GB RAM) | Harmonia binary cache, Btrfs, Custom ALSA profile |
