---
title: NixOS System Modules
description: Modular NixOS system-level configurations, daemon management, hardware quirks, and security policies.
---

This directory contains modular, reusable **NixOS system-level** configurations. Unlike `home/`, configurations here operate in the root NixOS system scope (`config`, `pkgs`, `lib`) and manage hardware devices, systemd system services, PAM, udev rules, network interfaces, and security policies.

---

## Module Taxonomy

| Category | Path | Description |
| :--- | :--- | :--- |
| **`core/`** | `modules/core/` | Baseline system configuration applied across all hosts (bootloader, networking, security policies, user accounts, system fonts, and core packages). |
| **`hyprland/`** | `modules/hyprland/` | Hyprland Wayland compositor, UWSM session integration, and Ly display manager greeter. |
| **`desktop/`** | `modules/desktop/` | Shared workstation capabilities and desktop services (network shares, desktop portal helpers). |
| **`laptop/`** | `modules/laptop/` | Portable device power management, battery optimization profiles, and sleep/wake handling. |
| **`hardware/`** | `modules/hardware/` | Vendor-specific hardware integrations and firmware utilities (e.g. `framework.nix`). |
| **`wireless/`** | `modules/wireless/` | Wireless networking (Wi-Fi), network management, and Bluetooth stack. |
| **`vpn/`** | `modules/vpn/` | Virtual Private Network (VPN) client services, WireGuard tunnels, and encrypted routing. |
| **`gaming/`** | `modules/gaming/` | Steam, Gamescope, and graphics/system performance optimizations (see [Gaming & Gamescope](/gaming/)). |
| **`sunshine/`** | `modules/sunshine/` | Low-latency Sunshine desktop and game streaming server with zero-touch tablet display automation (see [Sunshine Streaming](/sunshine/)). |
| **`ai/`** | `modules/ai/` | Hardware-accelerated compute runtimes (ROCm/CUDA), local AI engines, and inference services. |
| **`secrets/`** | `modules/secrets/` | System secret management, decryption, and credential provisioning via agenix. |
| **`input-method/`** | `modules/input-method/` | Input method engines (Fcitx5), internationalization, and character input mappings. |
| **`shell-scripts/`** | `modules/shell-scripts/` | Custom CLI utilities packaged via `writeShellApplication` (see [Custom Shell Scripts](/shell-scripts/)). |
| **`home-manager/`** | `modules/home-manager/` | System-level Home Manager integration module binding user configurations and automatic per-host home extensions. |
| **`lanzaboote/`** | `modules/lanzaboote/` | UEFI Secure Boot integration and cryptographic bootloader signing. |
| **`power-management/`** | `modules/power-management/` | Power management daemons and system power profile switching. |
| **`config/`** | `modules/config/` | Shared, host-reusable system configurations intended to be imported on demand. |

> [!IMPORTANT]
> **`modules/config/` Usage**: This directory contains optional shared configs. Do **not** import `modules/config/` wholesale; import individual files into a host's `extraModules` as needed.

---

## Guidelines for Authoring System Modules

1. **System vs. Home Manager Scope:**
   - Place a tool in `modules/` if it requires root privileges, kernel modules, systemd system services, PAM, or udev rules.
   - Place a tool in `home/` if it is a user application, shell alias, terminal emulator, or editor.

2. **Reusability & Host Independence:**
   - Modules in this directory must remain host-agnostic. Avoid hardcoding device bus IDs or hostnames.
   - Host-specific overrides or hardware bindings belong in `hosts/<hostname>/`.

3. **Packaging Scripts Standard:**
   - Custom CLI utilities are standardly packaged with `pkgs.writeShellApplication` and declared `runtimeInputs` (see [Custom Shell Scripts](/shell-scripts/) for conventions).
