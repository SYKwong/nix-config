# Flatpak System Module (`modules/flatpak/`)

This module provides declarative Flatpak management on NixOS powered by [`nix-flatpak`](https://github.com/gmodena/nix-flatpak).

It is designed as an **on-demand module with host-level auto-discovery**:
- When not imported into a host or system configuration, Flatpak is completely disabled with zero runtime or build overhead.
- When imported, it automatically discovers and includes host-specific packages from `hosts/<hostname>/flatpak.nix` if present, mirroring the `hosts/<hostname>/home/` pattern used by Home Manager.

---

## 1. Enabling the Module

To activate Flatpak, import `./modules/flatpak`:

### For a Specific Host Only (Recommended)
In [`outputs.nix`](../../outputs.nix), add `./modules/flatpak` to the host's `extraModules`:

```nix
mini-pc-k8 = {
  username = "k8-kyle";
  system = "x86_64-linux";

  extraModules = [
    ...
    ./modules/flatpak  # <-- Enables Flatpak for this host
  ];
};
```

### Or Globally for All Hosts
In [`outputs.nix`](../../outputs.nix), add `./modules/flatpak` to the root `modules` list:

```nix
modules = [
  disko.nixosModules.disko
  home-manager.nixosModules.home-manager
  stylix.nixosModules.stylix
  agenix.nixosModules.default

  ./modules/core
  ./modules/flatpak    # <-- Enables Flatpak for all machines
  ...
]
```

---

## 2. Declaring Host-Specific Packages (`hosts/<hostname>/flatpak.nix`)

Each host can maintain its own isolated list of Flatpak packages without touching shared modules.

Create a `flatpak.nix` file inside the host directory (e.g. `hosts/mini-pc-k8/flatpak.nix`):

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
> [`modules/flatpak/default.nix`](./default.nix) automatically detects and imports `hosts/<hostname>/flatpak.nix` if it exists. No additional wiring is required.

---

## 3. Declaring Common Packages (Optional)

If certain Flatpak applications should be installed on **every** host that enables Flatpak, declare them directly in [`modules/flatpak/default.nix`](./default.nix):

```nix
services.flatpak.packages = [
  "com.github.tchx84.Flatseal"
];
```

Host-specific packages declared in `hosts/<hostname>/flatpak.nix` merge with common packages automatically.

---

## 4. Finding Application IDs

Flatpak packages are identified by their reverse-DNS App ID:
1. Search [Flathub](https://flathub.org) in a web browser. The App ID appears at the bottom of the application page and in the URL (e.g. `https://flathub.org/apps/com.spotify.Client` $\rightarrow$ `com.spotify.Client`).
2. Search via CLI (when Flatpak is active):
   ```bash
   flatpak search <app-name>
   ```

---

## 5. Configuring Remotes

The Flathub repository is pre-configured by default. To declare custom or third-party remotes (in `modules/flatpak/default.nix` or host-level `flatpak.nix`):

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

Sandbox permissions and environment variables can be declared globally in [`modules/flatpak/default.nix`](./default.nix) or per-host in `hosts/<hostname>/flatpak.nix`:

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

## 7. Applying Changes & Updates

1. Rebuild the system to install newly declared packages:
   ```bash
   nrs
   ```
2. **Auto-Updates:**
   - **Activation:** Running `nrs` updates declared packages during system activation (`services.flatpak.update.onActivation = true;`).
   - **Periodic Timer:** A background systemd timer updates Flatpak packages weekly (`services.flatpak.update.auto.enable = true;`).
3. **Declarative Removal & Pruning:**
   - Removing an entry from `services.flatpak.packages` automatically uninstalls the package on the next activation (`uninstallUnmanaged = true;`).
   - Orphaned runtimes and extensions are automatically pruned (`uninstallUnused = true;`).

