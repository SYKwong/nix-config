# Secret Management with Agenix (`secrets/`)

This directory manages encrypted system credentials, API tokens, and cryptographic keys using [agenix](https://github.com/ryantm/agenix).

> [!IMPORTANT]
> **Adopting This Repository**: All `.age` files in this directory are encrypted with the author's private keys. Running `./adopt.sh <hostname> <username>` automatically purges these secrets and resets `keys.nix` and `secrets.nix`.

---

## Directory Taxonomy

```text
secrets/
├── keys.nix                    # Public keys single source of truth (users and systems)
├── secrets.nix                 # Secret definitions and recipient key access rules
├── *.age                       # Encrypted secret vaults
└── README.md                   # Architecture, active secrets, and workflows
```

---

## Active Fleet Secrets

| Secret File | Decrypted Path | Purpose |
| :--- | :--- | :--- |
| `atuin-credentials.age` | `/run/agenix/atuin-credentials` | Atuin cross-machine shell history sync credentials & 24-word key |
| `cloudflare-workers-ai-apikey.age` | `/run/agenix/cloudflare-workers-ai-apikey` | Cloudflare Workers AI API token for CLI utilities |
| `harmonia-signing-key.age` | `/run/agenix/harmonia-signing-key` | Local binary cache package signing key |
| `smb-credentials.age` | `/run/agenix/smb-credentials` | Network share credentials for local NAS storage |
| `wireguard-fw16.age` | `/run/agenix/wireguard-fw16` | WireGuard VPN client private key (`framework16`) |

---

## Key Architecture

Public keys are defined in [`keys.nix`](keys.nix) as the single source of truth across the repository:

* **User Keys (`keys.users`)**: Individual human user keys (`~/.ssh/id_ed25519.pub`). Used to decrypt and edit secrets locally without root privileges, and imported into [`modules/core/ssh.nix`](../modules/core/ssh.nix) for fleet SSH access.
* **System Keys (`keys.systems`)**: Host machine keys (`/etc/ssh/ssh_host_ed25519_key.pub`). Used by systemd / root to autonomously decrypt system secrets at boot time.

Secrets in [`secrets.nix`](secrets.nix) are encrypted to **both** user and system keys so you can edit them comfortably as an unprivileged user while NixOS decrypts them at boot.

---

## Common Workflows

### Edit an Existing Secret
```bash
cd secrets
agenix -e <secret-name>.age
```

### Create a New Secret
1. Add the secret and allowed recipient keys to [`secrets.nix`](secrets.nix):
   ```nix
   "my-secret.age".publicKeys = [ users.kyle systems.framework16 ];
   ```
2. Create and edit the encrypted secret:
   ```bash
   cd secrets
   agenix -e my-secret.age
   ```
3. Reference the secret in your NixOS configuration (e.g. `hosts/<hostname>/config.nix`):
   ```nix
   age.secrets.my-secret.file = ../../secrets/my-secret.age;
   ```
   At runtime, NixOS decrypts the secret to `/run/agenix/my-secret` (accessible via `config.age.secrets.my-secret.path`).

### Rekey Secrets (Adding or Rotating Keys)
1. Run `./post-install.sh` on the new machine to generate host keys and insert them into [`keys.nix`](keys.nix) (or add them manually).
2. Ensure the host or user key is in the recipient list in [`secrets.nix`](secrets.nix) (hosts in `keys.systems` are included automatically in `allKeys`).
3. Re-encrypt all secrets on an authorized machine with access to an existing private key:
   ```bash
   cd secrets
   agenix --rekey
   ```

---

## Atuin History Sync Quick Reference (`atuin-credentials.age`)

Atuin auto-authenticates upon `nrs` via `atuin-auto-login` when `/run/agenix/atuin-credentials` is present. Expected format:

```env
ATUIN_USERNAME="<your-username>"
ATUIN_PASSWORD="<your-password>"
ATUIN_KEY="word1 word2 word3 ... word24"
```
*(Retrieve your 24-word key on an existing machine using `atuin key`, or create an account with `atuin register`).*

---

## Documentation

For recipient key distribution details, step-by-step account onboarding, and recovery procedures, refer to the online guide:

📖 **[Secret Management with Agenix Documentation](https://nix.kyle-kwong.com/secrets/)**
