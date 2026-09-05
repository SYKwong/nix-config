# Secret Management with Agenix

This directory manages encrypted secrets using [agenix](https://github.com/ryantm/agenix).

---

## 1. Key Architecture & Single Source of Truth

Public keys are defined in [`keys.nix`](keys.nix) as the single source of truth across the repository:

* **User Keys (`keys.users`)**:
  * **Identity**: Represents individual human users (`~/.ssh/id_ed25519.pub`).
  * **Role**: Used by you to decrypt and edit secrets locally without root privileges, and automatically imported into [`modules/core/ssh.nix`](../modules/core/ssh.nix) for authorized SSH access.
* **System Keys (`keys.systems`)**:
  * **Identity**: Represents the machine host itself (`/etc/ssh/ssh_host_ed25519_key.pub`).
  * **Role**: Used by the operating system (systemd / root) to autonomously decrypt system secrets at boot time without human intervention.

Secrets in [`secrets.nix`](secrets.nix) are encrypted to **both** user and system keys so that you can edit them comfortably as a user, while NixOS can decrypt them during boot.

---

## 2. Common Workflows

### Edit an Existing Secret
Run `agenix` from within the `secrets/` directory (it will use your `~/.ssh/id_ed25519` key to open your `$EDITOR`):

```bash
cd secrets
agenix -e <secret-name>.age
```

### Create a New Secret
1. Add the secret and its allowed recipient keys to [`secrets.nix`](secrets.nix):
   ```nix
   "my-secret.age".publicKeys = fw16;
   ```
2. Create and edit the encrypted secret:
   ```bash
   cd secrets
   agenix -e my-secret.age
   ```
3. Reference the secret in your NixOS configuration:
   ```nix
   age.secrets.my-secret.file = ../../secrets/my-secret.age;
   ```
   At runtime, NixOS decrypts the secret to `/run/agenix/my-secret` (accessible via `config.age.secrets.my-secret.path`).

### Rekey Secrets (Adding or Rotating Keys)
When adding a new machine, user key, or rotating keys:
1. Add the new public key to [`keys.nix`](keys.nix).
2. Update the target list in [`secrets.nix`](secrets.nix).
3. Re-encrypt all existing secrets for the updated recipient list:
   ```bash
   cd secrets
   agenix --rekey
   ```
