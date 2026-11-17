---
title: Welcome to nix-config
description: Declarative, multi-host NixOS and Home Manager configuration fleet.
template: splash
hero:
  tagline: Declarative multi-host NixOS and Home Manager configuration fleet managing workstations, laptops, and gaming consoles.
  actions:
    - text: System Installation
      link: /nix-config/installation/
      icon: right-arrow
      variant: primary
    - text: Flake Architecture
      link: /nix-config/architecture/
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
| **Getting Started** | Setting up new machines from scratch | [System Installation](/nix-config/installation/) • [Adoption & Forking](/nix-config/adoption/) • [Post-Installation](/nix-config/post-installation/) • [BIOS & Firmware](/nix-config/bios-update/) |
| **Architecture** | Flake organization and machine topologies | [Flake Architecture](/nix-config/architecture/) • [Split CI Architecture](/nix-config/split-ci/) • [Hosts Inventory](/nix-config/hosts/) • [Home Manager](/nix-config/home-manager/) • [Dotfiles](/nix-config/dotfiles/) |
| **Modules** | Reusable system capabilities and integrations | [System Modules](/nix-config/modules/) • [Sunshine Streaming](/nix-config/sunshine/) • [Gaming & Gamescope](/nix-config/gaming/) • [Flatpak](/nix-config/flatpak/) • [Shell Scripts](/nix-config/shell-scripts/) • [Overlays](/nix-config/overlays/) |
| **Operations** | Day-to-day maintenance and security | [Secrets (agenix)](/nix-config/secrets/) • [Desktop Entries](/nix-config/desktop-entries/) • [Code Quality](/nix-config/code-quality/) |

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
# Format and lint code (Nix, Bash, C/C++, Lua, TOML via treefmt)
nix fmt

# Flake evaluation check
nix flake check
```

---

## Active Fleet Inventory

| Host | Role | Hardware | Key Technologies |
| :--- | :--- | :--- | :--- |
| **[`framework16`](/nix-config/hosts/)** | Primary Workstation Laptop | Framework Laptop 16 (AMD Ryzen 7840HS, 96GB RAM) | LUKS + TPM2, Lanzaboote Secure Boot, Btrfs + Swap Hibernation |
| **[`mini-pc-k8`](/nix-config/hosts/)** | HTPC / Living Room Desktop | GMKtec NucBox K8 Plus (AMD Ryzen 8845HS, 64GB RAM) | Btrfs, Custom ALSA profile, Flake update verifier |
