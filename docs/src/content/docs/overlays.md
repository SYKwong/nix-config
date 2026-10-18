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

---

## Consuming Packages from Nixpkgs Stable (or Other Channels)

The fleet defaults entirely to `nixpkgs/nixos-unstable`. If a package ever requires pinning to `nixpkgs-stable` (for example, due to an upstream regression on unstable), you can re-introduce the stable channel via an overlay or `specialArgs`:

### 1. Declare the Flake Input

Add the desired channel to `inputs` in `flake.nix`:

```nix
inputs = {
  nixpkgs.url = "nixpkgs/nixos-unstable";
  nixpkgs-stable.url = "nixpkgs/nixos-26.05";
  # ...
};
```

### 2. Expose via an Overlay (Recommended)

Create an overlay in `overlays/stable.nix` that mounts the stable package set onto `pkgs.stable`:

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

Add `./stable.nix` to `imports` in `overlays/default.nix`.

### 3. Consume in Modules

Any NixOS or Home Manager module can then access stable packages directly through the standard `pkgs` argument without altering module function signatures:

```nix
{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.stable.some-pinned-package
  ];
}
```

> [!NOTE]
> Alternatively, you can inject `pkgs-stable` into `specialArgs` in `outputs.nix` (`pkgs-stable = inputs.nixpkgs-stable.legacyPackages.x86_64-linux;`), but the overlay approach above is preferred as it keeps module parameter signatures uniform across the fleet.
