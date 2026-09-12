# NixOS System Modules (`modules/`)

This directory contains modular, reusable **NixOS system-level** configurations. Unlike [`home/`](../home), configurations here operate in the root NixOS system scope (`config`, `pkgs`, `lib`) and manage hardware, systemd services, udev rules, security, and global packages.

---

## Directory Taxonomy

| Category | Description |
| :--- | :--- |
| **`core/`** | Baseline system configurations applied across all hosts (bootloader, networking, security policies, user accounts, system fonts, and core packages). |
| **`display-manager/`** | Graphical login managers, display greeters, and session initializers. |
| **`window-manager/`** | Wayland compositors, window managers, and graphical session management. |
| **`desktop/`** | Shared workstation capabilities and desktop services (e.g., network filesystem shares, desktop integration helpers). |
| **`laptop/`** | Portable device power management, battery optimization profiles, and sleep/wake handling. |
| **`framework/`** | Framework laptop hardware integrations, fan curve controls, and firmware utilities. |
| **`wireless/`** | Wireless networking (Wi-Fi), network management, and Bluetooth services. |
| **`vpn/`** | Virtual Private Network (VPN) client services, daemons, and encrypted tunnels. |
| **`gaming/`** | Gaming platforms, compatibility runtimes, and graphics/system performance optimizations. |
| **`media/`** | Media streaming servers, headless playback daemons, and audio services. |
| **`ai/`** | Hardware-accelerated compute runtimes, local AI engines, and inference services. |
| **`secrets/`** | System secret management, decryption, and credential provisioning. |
| **`input/`** | Input method engines (IME), internationalization, and keyboard layout mappings. |
| **`shell-scripts/`** | Custom CLI utilities packaged via `writeShellApplication` (see [`modules/shell-scripts/README.md`](./shell-scripts/README.md)). |
| **`home-manager/`** | System-level Home Manager integration module binding user configurations and `extraHomeModules`. |
| **`lanzaboote/`** | UEFI Secure Boot integration and cryptographic bootloader signing. |
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
