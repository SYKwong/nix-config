# Systemd Services & Timers (`modules/systemd-services/`)

This directory contains standalone NixOS systemd background services and scheduled timer units that do not belong to domain-specific modules (such as `sunshine/`, `vpn/`, or `wireless/`).

---

## Directory Taxonomy

```text
modules/systemd-services/
├── default.nix                 # Imports active systemd service modules
├── flake-update-verifier.nix   # Overnight flake update MR build verification and auto-merge service
├── README.md                   # Directory overview and unit index
└── wallpaper-sync.nix          # Daily wallpaper repository synchronization user timer and service
```

---

## Units

| Unit | Scope | Type | Description |
| :--- | :--- | :--- | :--- |
| **`wallpaper-sync`** | User (`systemd.user`) | Timer + Oneshot Service | Runs daily to execute `wallpaper-sync`, pulling remote updates and pushing local changes for `~/Wallpaper`. Enabled by default across workstation hosts (`custom.systemd-services.wallpaper-sync.enable`). |
| **`flake-update-verifier`** | User (`systemd.user`) | Timer + Oneshot Service | Runs overnight (`03:00–07:00`) on workstations (`mini-pc-k8`) to build test open dependency MRs, label failed MRs with `build-error` and post build error excerpts, and auto-merge verified updates via `glab` (`custom.systemd-services.flake-update-verifier.enable`). |

---

## Documentation

For full details on modular NixOS system configuration, refer to the online guide:

📖 **[NixOS System Modules Documentation](https://nix.kyle-kwong.com/modules/)**
