# Systemd Services & Timers (`modules/systemd-services/`)

This directory contains standalone NixOS systemd background services and scheduled timer units that do not belong to domain-specific modules (such as `sunshine/`, `vpn/`, or `wireless/`).

---

## Directory Taxonomy

```text
modules/systemd-services/
├── default.nix                 # Imports active systemd service modules
├── README.md                   # Directory overview and unit index
└── wallpaper-sync.nix          # Daily wallpaper repository synchronization user timer and service
```

---

## Units

| Unit | Scope | Type | Description |
| :--- | :--- | :--- | :--- |
| **`wallpaper-sync`** | User (`systemd.user`) | Timer + Oneshot Service | Runs daily to execute `wallpaper-sync`, pulling remote updates and pushing local changes for `~/Wallpaper`. |

---

## Documentation

For full details on modular NixOS system configuration, refer to the online guide:

📖 **[NixOS System Modules Documentation](https://nix.kyle-kwong.com/modules/)**
