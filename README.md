# nix-config

[![Documentation](https://img.shields.io/badge/docs-nix.kyle--kwong.com-blue?style=flat-square)](https://nix.kyle-kwong.com)
[![License: MIT-0](https://img.shields.io/badge/license-MIT--0-green?style=flat-square)](https://spdx.org/licenses/MIT-0.html)

Declarative multi-host **NixOS** and **Home Manager** configuration fleet managing workstations, laptops, and gaming consoles.

📚 **Documentation & Wiki:** [**nix.kyle-kwong.com**](https://nix.kyle-kwong.com)

---

## Active Fleet

| Host | Form Factor | Hardware | Highlights | Config |
| :--- | :--- | :--- | :--- | :--- |
| **`framework16`** | Workstation Laptop | Framework Laptop 16 (Ryzen 7840HS, 96GB RAM) | LUKS + TPM2, Lanzaboote Secure Boot, 100GB swap hibernation | [`hosts/framework16`](./hosts/framework16/) |
| **`mini-pc-k8`** | Living Room HTPC | GMKtec NucBox K8 Plus (Ryzen 8845HS, 64GB RAM) | Btrfs, custom ALSA profile, Flatpak discovery | [`hosts/mini-pc-k8`](./hosts/mini-pc-k8/) |

---

## Quick Start

### 1. Adopting for Your Own Hardware
Before installing, **fork this repository** to your own GitLab or GitHub account, then sanitize personal credentials and scaffold your target machine profile using the automated adoption script:

```bash
# 1. Clone YOUR fork:
git clone https://github.com/<your-username>/nix-config.git  # or https://gitlab.com/<your-username>/nix-config.git
cd nix-config

# 2. Sanitize personal credentials and scaffold your machine:
./adopt.sh <your-hostname> <your-username> [--laptop | --desktop] [--luks]

# 3. Verify or edit your persistent drive ID in hosts/<your-hostname>/disko.nix:
#    device = "/dev/disk/by-id/..." (discover via: ls -l /dev/disk/by-id/)

# 4. Commit and push to your fork:
git add .
git commit -m "feat: adopt configuration for <your-hostname>"
git push origin main
```

> 📖 **Full Guide:** [**Adoption & Forking Guide**](https://nix.kyle-kwong.com/adoption/)

---

### 2. Bootstrapping a New Machine
Boot into a **NixOS Live USB** environment with active networking:

```bash
# 1. Clone your fork in the live environment:
git clone https://github.com/<your-username>/nix-config.git  # or https://gitlab.com/<your-username>/nix-config.git
cd nix-config

# 2. Run the automated installer (pre-installed on custom ISO, or via nix run):
sudo install-nixos "<your-hostname>" "<user_password>" ["<luks_password>"]
# Or on generic live media:
sudo nix run .#install-nixos -- "<your-hostname>" "<user_password>" ["<luks_password>"]
```

After installation and rebooting into your new system, complete automated onboarding:

```bash
post-install
```

> 📖 **Full Guides:** [**System Installation Guide**](https://nix.kyle-kwong.com/installation/) • [**Post-Installation Setup**](https://nix.kyle-kwong.com/post-installation/)

---

## Daily Driver Cheatsheet

```bash
# Rebuild and activate live system generation
nrs

# Format and lint code (Nix, Bash, Lua, TOML via treefmt)
nix fmt

# Flake evaluation check
nix flake check

# Stage, commit with Conventional Commits, and push
git lazy "<commit message>"
```

---

## Documentation Index

The complete documentation is maintained in-tree under [`docs/`](./docs/) and deployed to [**nix.kyle-kwong.com**](https://nix.kyle-kwong.com):

| Category | Key Pages |
| :--- | :--- |
| **Getting Started** | [System Installation](https://nix.kyle-kwong.com/installation/) • [Adoption & Forking](https://nix.kyle-kwong.com/adoption/) • [Post-Installation Setup](https://nix.kyle-kwong.com/post-installation/) • [BIOS & Firmware Updates](https://nix.kyle-kwong.com/bios-update/) |
| **Architecture & Fleet** | [Flake Architecture](https://nix.kyle-kwong.com/architecture/) • [Split CI Architecture](https://nix.kyle-kwong.com/split-ci/) • [Host Configurations](https://nix.kyle-kwong.com/hosts/) • [Home Manager](https://nix.kyle-kwong.com/home-manager/) • [Out-of-Store Dotfiles](https://nix.kyle-kwong.com/dotfiles/) |
| **Modules & Features** | [System Modules](https://nix.kyle-kwong.com/modules/) • [Gaming & Gamescope](https://nix.kyle-kwong.com/gaming/) • [Sunshine Streaming & Tablet Display](https://nix.kyle-kwong.com/sunshine/) • [Declarative Flatpak](https://nix.kyle-kwong.com/flatpak/) • [Custom Shell Scripts](https://nix.kyle-kwong.com/shell-scripts/) • [Nixpkgs Overlays](https://nix.kyle-kwong.com/overlays/) |
| **Guides & Operations** | [Secrets Management (Agenix)](https://nix.kyle-kwong.com/secrets/) • [Managing Desktop Entries](https://nix.kyle-kwong.com/desktop-entries/) • [Code Quality & Evaluation](https://nix.kyle-kwong.com/code-quality/) |

---

## License & Attributions

- Configuration files and scripts are licensed under [MIT-0](https://spdx.org/licenses/MIT-0.html) (no attribution required, but appreciated).
- Repository icon: NixOS logo, licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) by the NixOS project.
- `icons/protontricks.svg`: Wine icon from KDE Breeze Icons, licensed under [LGPL-3.0-or-later](https://invent.kde.org/frameworks/breeze-icons/-/blob/master/COPYING-ICONS).
