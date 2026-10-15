---
title: Declarative Flatpak
description: Declarative, reproducible Flatpak application management with host-level auto-discovery via nix-flatpak.
---

This module provides declarative, reproducible Flatpak application management on NixOS powered by [`nix-flatpak`](https://github.com/gmodena/nix-flatpak).

It operates on an **on-demand model with host-level auto-discovery**:
- When not imported into a host, Flatpak is completely disabled with zero runtime or build overhead.
- When imported, it automatically discovers and includes host-specific packages from `hosts/<hostname>/flatpak.nix` if present, mirroring the `hosts/<hostname>/home/` pattern used by Home Manager.

---

## 1. Enabling the Module

### For a Specific Host Only (Recommended)
In `outputs.nix`, add `./modules/flatpak` to the host's `extraModules`:

```nix
<host_name> = {
  username = "<user_name>";
  system = "x86_64-linux";

  extraModules = [
    # ...
    ./modules/flatpak  # <-- Enables Flatpak for this host
  ];
};
```

### Or Globally for All Hosts
In `outputs.nix`, add `./modules/flatpak` to the root `modules` list:

```nix
modules = [
  disko.nixosModules.disko
  home-manager.nixosModules.home-manager
  stylix.nixosModules.stylix
  agenix.nixosModules.default

  ./modules/core
  ./modules/flatpak    # <-- Enables Flatpak across all machines
  # ...
]
```

---

## 2. Declaring Host-Specific Packages (`hosts/<hostname>/flatpak.nix`)

Each host can maintain its own isolated list of Flatpak packages without touching shared modules. Create a `flatpak.nix` file inside the host directory (e.g. `hosts/<hostname>/flatpak.nix`):

```nix
{
  services.flatpak.packages = [
    # Simple format (defaults to the "flathub" origin):
    "com.spotify.Client"
    "com.github.tchx84.Flatseal"

    # Attribute set format (for custom origins, branches, or architectures):
    {
      appId = "org.mozilla.firefox";
      origin = "flathub";
    }
  ];
}
```

> [!NOTE]
> `modules/flatpak/default.nix` automatically detects and imports `hosts/<hostname>/flatpak.nix` if it exists. No additional wiring is required.

---

## 3. Declaring Common Packages

If certain Flatpak applications should be installed on **every** host that enables Flatpak, declare them in `modules/flatpak/default.nix`:

```nix
services.flatpak.packages = [
  "com.github.tchx84.Flatseal"
];
```

Host-specific packages merge with common packages automatically.

---

## 4. Finding Application IDs

Flatpak packages are identified by their reverse-DNS App ID:
1. **Flathub Web:** Search [Flathub](https://flathub.org). The App ID appears at the bottom of the page and in the URL (e.g. `https://flathub.org/apps/com.spotify.Client` → `com.spotify.Client`).
2. **CLI Search (when Flatpak is active):**
   ```bash
   flatpak search <app-name>
   ```

---

## 5. Configuring Custom Remotes

Flathub is pre-configured by default. To declare third-party or beta repositories:

```nix
services.flatpak.remotes = [
  {
    name = "flathub";
    location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  }
  {
    name = "flathub-beta";
    location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
  }
];
```

---

## 6. Sandbox Permissions & Overrides

Sandbox permissions and environment variables can be declared globally in `modules/flatpak/default.nix` or per-host in `hosts/<hostname>/flatpak.nix`:

```nix
services.flatpak.overrides = {
  # Global overrides for all Flatpak applications on this host:
  global = {
    Context.filesystems = [ "xdg-download" ];
    Environment = {
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  # App-specific overrides:
  "com.spotify.Client" = {
    Context.filesystems = [ "xdg-music:ro" ];
  };
};
```

---

## 7. Lifecycle, Updates & Pruning

1. **Activation:** Rebuild the system with `nrs` to install declared packages. Packages are also updated during system activation (`services.flatpak.update.onActivation = true;`).
2. **Periodic Updates:** A background systemd timer automatically checks and updates Flatpak packages weekly (`services.flatpak.update.auto.enable = true;`).
3. **Declarative Pruning:**
   - Removing an entry from `services.flatpak.packages` automatically uninstalls the package on the next activation (`uninstallUnmanaged = true;`).
   - Orphaned runtimes and unused dependencies are automatically pruned (`uninstallUnused`, which defaults to `uninstallUnmanaged`).
