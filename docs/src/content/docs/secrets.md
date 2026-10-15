---
title: Secret Management with Agenix
description: Managing encrypted system credentials, tokens, and cryptographic keys using agenix.
---

This directory (`secrets/`) manages encrypted system credentials, tokens, and cryptographic keys using [agenix](https://github.com/ryantm/agenix).

---

## 1. Key Architecture & Single Source of Truth

Public keys are defined in `secrets/keys.nix` as the single source of truth across the repository:

* **User Keys (`keys.users`)**:
  * **Identity:** Represents individual human users (`~/.ssh/id_ed25519.pub`).
  * **Role:** Used to decrypt and edit secrets locally without root privileges, and automatically imported into `modules/core/ssh.nix` for authorized SSH fleet access.
* **System Keys (`keys.systems`)**:
  * **Identity:** Represents the physical machine host (`/etc/ssh/ssh_host_ed25519_key.pub`).
  * **Role:** Used by the operating system (systemd / root) to autonomously decrypt system secrets during early boot without human intervention.

Secrets in `secrets/secrets.nix` are encrypted to **both** user and system keys so that you can edit them comfortably as an unprivileged user, while NixOS can decrypt them automatically during boot.

---

## 2. Common Workflows

### Edit an Existing Secret
Run `agenix` from within the `secrets/` directory (it will use your `~/.ssh/id_ed25519` key to open your `$EDITOR`):

```bash
cd secrets
agenix -e <secret-name>.age
```

### Create a New Secret
1. Declare the secret and its allowed recipient keys in `secrets/secrets.nix`:
   ```nix
   "my-secret.age".publicKeys = fw16;
   ```
2. Create and edit the encrypted secret file:
   ```bash
   cd secrets
   agenix -e my-secret.age
   ```
3. Reference the secret in your NixOS configuration (e.g. `hosts/<hostname>/config.nix`):
   ```nix
   age.secrets.my-secret.file = ../../secrets/my-secret.age;
   ```
   At runtime, NixOS decrypts the secret to `/run/agenix/my-secret` (accessible via `config.age.secrets.my-secret.path`).

### Rekey Secrets (Adding a New Host or Rotating Keys)
When adding a new machine, changing user keys, or rotating credentials:
1. Run [`./post-install.sh`](/post-installation/) on the new machine to automatically generate keys and insert them into `secrets/keys.nix` (or add them manually).
2. Ensure the host or user key is included in the recipient list in `secrets/secrets.nix` (new hosts added to `keys.systems` are included automatically in `allKeys`).
3. Re-encrypt all existing secrets on an authorized machine with access to an existing private key:
   ```bash
   cd secrets
   agenix --rekey
   ```
4. Commit and push the re-encrypted `.age` files.
