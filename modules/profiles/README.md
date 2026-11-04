# System Profiles (`modules/profiles/`)

This directory contains form-factor system profiles (`desktop`, `laptop`). Profiles compose reusable NixOS system modules to define the high-level operating persona and hardware behavior of a machine.

---

## Profile Taxonomy

| Profile | Target Form Factor | Characteristics & Included Modules |
| :--- | :--- | :--- |
| **[`desktop/`](./desktop)** | Fixed workstations & HTPCs (`mini-pc-k8`) | Persistent wired/wireless networking, static CIFS NAS automounts (`fileSystems.<mount>`), power-profiles-daemon. |
| **[`laptop/`](./laptop)** | Portable clamshell notebooks (`framework16`) | Lid switch handling, dynamic NAS reachability daemon (`check-nas-cifs`), power-profiles-daemon, `suspend-then-hibernate`. |

---

## Directory Taxonomy

```text
modules/profiles/
├── desktop/
│   ├── default.nix             # Desktop profile entrypoint
│   ├── networkshare.nix        # Static CIFS NAS automounts
│   └── wireless-config.nix     # Workstation wireless defaults
├── laptop/
│   ├── default.nix             # Laptop profile entrypoint
│   ├── networkshare.nix        # Dynamic CIFS reachability daemon (check-nas-cifs)
│   └── sleep.nix               # Clamshell lid and sleep-then-hibernate behavior
└── README.md                   # Architecture taxonomy and guidelines
```

---

## Documentation

For fleet architecture and host profile composition, refer to the online guide:

📖 **[System Profiles Documentation](https://nix.kyle-kwong.com/hosts/)**
