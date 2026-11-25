# Shared System Configuration Helpers (`modules/config/`)

This directory contains reusable NixOS configuration helpers shared across multiple hosts and profiles. Do not import this directory as a whole—import each file explicitly as needed.

---

## File Map

| File                                                   | Purpose                                                                                                                 |
| :----------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------- |
| [`networkshare-config.nix`](./networkshare-config.nix) | Shared NAS/CIFS mount helper (`mkCifsFileSystem`) consumed by `modules/profiles/desktop` and `modules/profiles/laptop`. |

---

## Documentation

For system architecture and module organization, refer to the online guide:

📖 **[NixOS System Modules Documentation](https://nix.kyle-kwong.com/nix-config/modules/)**
