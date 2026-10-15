---
title: Nixpkgs Overlays
description: Nixpkgs overlays used to patch, modify, or extend packages across all hosts.
---

This directory (`overlays/`) contains Nixpkgs overlays used to patch, modify, or extend packages available in the global package set across all hosts.

---

## How It Works

1. `outputs.nix` imports `./overlays` as a top-level NixOS module for every host declared in the fleet.
2. Individual overlays are declared as separate `.nix` files in this directory and imported in `overlays/default.nix`.

---

## Adding a New Overlay

Create an overlay file (e.g. `overlays/my-package.nix`):

```nix
{
  nixpkgs.overlays = [
    (final: prev: {
      # Override or add custom package definitions:
      my-package = prev.my-package.overrideAttrs (oldAttrs: {
        # Custom patches, build flags, or version updates
      });
    })
  ];
}
```

Then register the new overlay by adding `./my-package.nix` to `imports` in `overlays/default.nix`.
