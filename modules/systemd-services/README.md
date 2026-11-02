# Systemd Services & Timers (`modules/systemd-services/`)

This directory contains standalone NixOS systemd background services and scheduled timer units that do not belong to domain-specific modules (such as `sunshine/`, `vpn/`, or `wireless/`).

---

## Directory Taxonomy

```text
modules/systemd-services/
├── default.nix                 # Imports active systemd service modules
├── flake-update-verifier.nix   # Overnight flake update MR build verification and auto-merge service
└── README.md                   # Directory overview and unit index
```

---

## Units

| Unit | Scope | Type | Description |
| :--- | :--- | :--- | :--- |
| **`flake-update-verifier`** | User (`systemd.user`) | Timer + Oneshot Service | Runs overnight (`03:00–07:00`) on workstations (`mini-pc-k8`) to rebase open dependency MRs onto `main`, build test all host closures, label failed MRs with `build-error` and post build error excerpts, and auto-merge verified updates via `glab` (`custom.systemd-services.flake-update-verifier.enable`). Also callable interactively via `nverify` (`flake-update-verifier --force`). |

---

## Documentation

For full details on modular NixOS system configuration, refer to the online guide:

📖 **[NixOS System Modules Documentation](https://nix.kyle-kwong.com/modules/)**
