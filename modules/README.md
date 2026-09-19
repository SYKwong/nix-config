# NixOS System Modules (`modules/`)

This directory contains modular, reusable **NixOS system-level** configurations. Unlike [`home/`](../home), configurations here operate in the root NixOS system scope (`config`, `pkgs`, `lib`) and manage hardware, systemd services, udev rules, security, and global packages.

---

## Directory Taxonomy

| Category | Description |
| :--- | :--- |
| **`core/`** | Baseline system configurations applied across all hosts (bootloader, networking, security policies, user accounts, system fonts, and core packages). |
| **`hyprland/`** | Hyprland Wayland compositor, UWSM session integration, and Ly display manager greeter. |
| **`desktop/`** | Shared workstation capabilities and desktop services (e.g., network filesystem shares, desktop integration helpers). |
| **`laptop/`** | Portable device power management, battery optimization profiles, and sleep/wake handling. |
| **`hardware/`** | Vendor-specific hardware integrations, device firmware utilities, and on-demand chassis configurations (e.g. `framework.nix`). |
| **`wireless/`** | Wireless networking (Wi-Fi), network management, and Bluetooth services. |
| **`vpn/`** | Virtual Private Network (VPN) client services, daemons, and encrypted tunnels. |
| **`gaming/`** | Gaming platforms, compatibility runtimes, and graphics/system performance optimizations. |
| **`ai/`** | Hardware-accelerated compute runtimes, local AI engines, and inference services. |
| **`secrets/`** | System secret management, decryption, and credential provisioning. |
| **`input-method/`** | Input method engines (IME), internationalization, and character input mappings. |
| **`shell-scripts/`** | Custom CLI utilities packaged via `writeShellApplication` (see [`modules/shell-scripts/README.md`](./shell-scripts/README.md)). |
| **`home-manager/`** | System-level Home Manager integration module binding user configurations and automatic per-host home extensions. |
| **`lanzaboote/`** | UEFI Secure Boot integration and cryptographic bootloader signing. |
| **`power-management/`** | Power management daemons and system power profile switching. |
| **`flatpak/`** | Declarative Flatpak application and sandbox runtime management (on-demand; see [`modules/flatpak/README.md`](./flatpak/README.md)). |
| **`config/`** | Shared, host-reusable system configurations intended to be imported on demand. |
| **`misc/`** | Miscellaneous auxiliary system services and utility integrations. |

---

## Guidelines for Authoring System Modules

1. **System vs. Home Manager Scope**:
   * If a tool requires root privileges, kernel modules, systemd system services, PAM, or udev rules, place it here in `modules/`.
   * If a tool is a user application, shell alias, terminal emulator, or editor, place it in [`home/`](../home).
2. **Reusability**:
   * Modules in this directory should be host-agnostic. Host-specific overrides or hardware bindings belong in [`hosts/<hostname>/`](../hosts).
3. **Packaging Scripts**:
   * Custom CLI utilities are standardly packaged with `pkgs.writeShellApplication` and declared `runtimeInputs` (see [`modules/shell-scripts/README.md`](./shell-scripts/README.md) for conventions and exceptions).
