---
title: Secret Management with Agenix
description: Managing encrypted system credentials, tokens, and cryptographic keys using agenix.
---

This directory (`secrets/`) manages encrypted system credentials, tokens, and cryptographic keys using [agenix](https://github.com/ryantm/agenix).

> [!IMPORTANT]
> **Adopting This Repository**: All `.age` files in this directory are encrypted with the author's private keys and are inaccessible to external users. Running `./adopt.sh <hostname> <username>` automatically purges these secrets and resets `secrets/keys.nix` and `secrets/secrets.nix`.
>
> Note that `home/cli/atuin.nix` expects `/run/agenix/atuin-credentials` for auto-login (which skips cleanly if absent; authenticate manually with `atuin login`).

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
1. Run [`post-install`](/post-installation/) on the new machine to automatically generate keys and insert them into `secrets/keys.nix` (or add them manually).
2. Ensure the host or user key is included in the recipient list in `secrets/secrets.nix` (new hosts added to `keys.systems` are included automatically in `allKeys`).
3. Re-encrypt all existing secrets on an authorized machine with access to an existing private key:
   ```bash
   cd secrets
   agenix --rekey
   ```
4. Commit and push the re-encrypted `.age` files.

---

## 3. Managed Fleet Secrets

| Secret File | Decrypted Path | Description |
| :--- | :--- | :--- |
| `smb-credentials.age` | `/run/agenix/smb-credentials` | Network share credentials for local NAS storage. |
| `cloudflare-workers-ai-apikey.age` | `/run/agenix/cloudflare-workers-ai-apikey` | API key for Cloudflare Workers AI. |
| `atuin-credentials.age` | `/run/agenix/atuin-credentials` | Atuin sync credentials for cross-machine shell history. |
| `wireguard-fw16.age` | `/run/agenix/wireguard-fw16` | WireGuard private key (`framework16`). |
| `harmonia-signing-key.age` | `/run/agenix/harmonia-signing-key` | Binary cache signing key (`mini-pc-k8`). |

---

## 4. Atuin Shell History Sync Setup (`atuin-credentials.age`)

Atuin uses client-side End-to-End Encryption (E2EE) with ChaCha20-Poly1305. The server (`api.atuin.sh`) never sees plaintext commands. Authenticating any device requires your account credentials and a **24-word client encryption key**.

### Step 1: Register or Retrieve Your Key

- **If you need a new account**:
  Register an account via `atuin register`:
  ```bash
  atuin register -u <username> -e <email> -p <password>
  ```
  Atuin creates your account on `api.atuin.sh` and prints your **24-word encryption key**. Save this key securely.
- **If you already have an account on another machine**:
  Retrieve your existing encryption key on an already authenticated machine by running:
  ```bash
  atuin key
  ```

### Step 2: Store Credentials in Agenix

Open `secrets/atuin-credentials.age` in your editor:

```bash
cd secrets
agenix -e atuin-credentials.age
```

Fill in your account username, password, and the 24-word encryption key:

```env
ATUIN_USERNAME="<your-username>"
ATUIN_PASSWORD="<your-password>"
ATUIN_KEY="word1 word2 word3 ... word24"
```

Save and exit (`:wq`). Agenix encrypts the secret to all fleet keys defined in `secrets.nix`.

### Step 3: Activate Across the Fleet

Trigger a rebuild:

```bash
nrs
```

NixOS decrypts the file to `/run/agenix/atuin-credentials`. The `atuin-auto-login` service automatically authenticates Atuin, enabling seamless cross-machine shell history and Fish autosuggestion synchronization.
