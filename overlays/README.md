# Nixpkgs Overlays (`overlays/`)

This directory contains Nixpkgs overlays used to patch, modify, or extend packages available in the global package set across all hosts.

---

## How It Works

1. [`outputs.nix`](../outputs.nix) imports `./overlays` as a top-level NixOS module for every host.
2. Individual overlays are declared as separate `.nix` files in this directory and imported in [`overlays/default.nix`](./default.nix).

---

## Adding a New Overlay

Create an overlay file (e.g. `overlays/my-package.nix`):

```nix
{
  nixpkgs.overlays = [
    (final: prev: {
      # Override or add custom package definitions:
      my-package = prev.my-package.overrideAttrs (oldAttrs: {
        # Custom patches or flags
      });
    })
  ];
}
```

Then add `./my-package.nix` to `imports` in [`overlays/default.nix`](./default.nix).

---

## Common Patterns

### 1. Patching an Upstream Package
```nix
{
  nixpkgs.overlays = [
    (final: prev: {
      package-name = prev.package-name.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [ ./fix.patch ];
      });
    })
  ];
}
```

### 2. Exposing Pinned Channels (`pkgs.stable`)
Mount stable channels onto `pkgs.stable` so any module can consume them cleanly:
```nix
{ inputs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      stable = import inputs.nixpkgs-stable {
        inherit (prev.stdenv.hostPlatform) system;
        config.allowUnfree = prev.config.allowUnfree;
      };
    })
  ];
}
```

---

## Documentation

For full details on existing fleet overlays and package overrides, refer to the online guide:

📖 **[Nixpkgs Overlays Documentation](https://nix.kyle-kwong.com/overlays/)**
