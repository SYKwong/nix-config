---
title: Declarative Flatpak (On-Demand Setup)
description: Archived reference and restoration guide for declarative Flatpak application management via nix-flatpak.
---

This page serves as an **archived reference and recipe** for declarative Flatpak management on NixOS powered by [`nix-flatpak`](https://github.com/gmodena/nix-flatpak).

Flatpak is currently **disabled and pruned** from the active fleet to reduce supply-chain surface area and lockfile churn. If a proprietary application or isolated runtime ever requires Flatpak in the future, follow this guide to restore the module on-demand.

---

## 1. Add Flake Input

Declare `nix-flatpak` in `inputs` of `flake.nix`. Check [nix-flatpak releases](https://github.com/gmodena/nix-flatpak/releases) to find and pin the latest release tag:

```nix
inputs = {
  # ...
  # Check https://github.com/gmodena/nix-flatpak/releases for the latest release tag (e.g. v0.7.0, v0.8.0, etc.)
  nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=vX.Y.Z";
};
```

---

## 2. Create the System Module (`modules/flatpak/default.nix`)

Create `modules/flatpak/default.nix` with host-level auto-discovery:

```nix
{
  inputs,
  lib,
  hostname,
  ...
}:

let
  hostFlatpak = ../../hosts/${hostname}/flatpak.nix;
in
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ]
  ++ lib.optional (builtins.pathExists hostFlatpak) hostFlatpak;

  services.flatpak = {
    enable = true;
    update = {
      onActivation = true;
      auto.enable = true;
    };
    uninstallUnmanaged = true;
  };
}
```

---

## 3. Enable the Module in `outputs.nix`

### For a Specific Host Only (Recommended)
Add `./modules/flatpak` to the host's `extraModules`:

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
Add `./modules/flatpak` to the root `modules` list in `outputs.nix`:

```nix
modules = [
  # ...
  ./modules/core
  ./modules/flatpak    # <-- Enables Flatpak across all machines
]
```

---

## 4. Declaring Host-Specific Packages (`hosts/<hostname>/flatpak.nix`)

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

## 5. Declaring Fleet-Wide Common Packages

If certain Flatpak applications should be installed on **every** host that enables Flatpak, declare them in `modules/flatpak/default.nix`:

```nix
services.flatpak.packages = [
  "com.github.tchx84.Flatseal"
];
```

Host-specific packages merge with common packages automatically.

---

## 6. Finding Application IDs

Flatpak packages are identified by their reverse-DNS App ID:
1. **Flathub Web:** Search [Flathub](https://flathub.org). The App ID appears at the bottom of the page and in the URL (e.g. `https://flathub.org/apps/com.spotify.Client` → `com.spotify.Client`).
2. **CLI Search (when Flatpak is active):**
   ```bash
   flatpak search <app-name>
   ```

---

## 7. Configuring Custom Remotes

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

## 8. Sandbox Permissions & Overrides

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

## 9. Lifecycle, Updates & Pruning

1. **Activation:** Rebuild the system with `nrs` to install declared packages. Packages are also updated during system activation (`services.flatpak.update.onActivation = true;`).
2. **Periodic Updates:** A background systemd timer automatically checks and updates Flatpak packages weekly (`services.flatpak.update.auto.enable = true;`).
3. **Declarative Pruning:**
   - Removing an entry from `services.flatpak.packages` automatically uninstalls the package on the next activation (`uninstallUnmanaged = true;`).
   - Orphaned runtimes and unused dependencies are automatically pruned (`uninstallUnused`, which defaults to `uninstallUnmanaged`).
