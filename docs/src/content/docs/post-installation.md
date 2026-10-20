---
title: Post-Installation & Onboarding
description: Onboarding steps for TPM2 hardware enrollment, SSH keys, repository remotes, and agenix secrets.
---

Following an automated installation via `install.sh`, complete the onboarding steps to configure cryptographic hardware bindings, SSH keys, repository remotes, and agenix secrets.

---

## Initial Boot

1. If using **LUKS + Secure Boot**:
   - Reboot into your BIOS setup.
   - Re-enable **Secure Boot**.
   - Save and exit BIOS.
2. At the boot prompt, unlock the system using your manual LUKS password (if prompted).
3. Log in with your user credentials.

---

## Running `post-install.sh`

Navigate to the cloned repository in your home directory (`~/nix-config`):

```bash
cd ~/nix-config
./post-install.sh
```

### What `post-install.sh` Does Automatically (Hands-off):
- **Converts Git Remote:** Converts `origin` from HTTPS to SSH (e.g. `git@gitlab.com:<your-username>/nix-config.git` or GitHub equivalent based on your clone URL).
- **Enrolls TPM2:** Automatically runs `systemd-cryptenroll` against PCR 7 (`--tpm2-device=auto --tpm2-pcrs=7`) if a LUKS container and TPM2 device are detected (automatically skipped on unencrypted storage).
- **Generates SSH Keys:** Creates ed25519 keys for both the host (`/etc/ssh/ssh_host_ed25519_key`) and the user (`~/.ssh/id_ed25519`) if they do not exist.
- **Registers Public Keys:** Injects the newly generated public keys directly into `secrets/keys.nix` under the current hostname.

---

## Interactive Service Authentication (`--auth`)

To authenticate command-line services and automatically register your new user SSH key with remote providers, run:

```bash
./post-install.sh --auth-only
```
*(Or run `./post-install.sh --auth` during initial setup).*

This interactive flow guides you through:
1. **Atuin Shell History Sync**: Shell history credentials (`secrets/atuin-credentials.age`) are managed declaratively via Agenix, authenticating the host automatically upon rebuild without interactive prompts. See the [Atuin Secret Setup](/secrets/#4-atuin-shell-history-sync-setup-atuin-credentialsage) guide for instructions on registering or obtaining your 24-word encryption key.
2. **GitHub CLI (`gh`)**: Authenticates via web session and uploads your public SSH key to your GitHub account.
3. **GitLab CLI (`glab`)**: Authenticates via web session and uploads your public SSH key to your GitLab account (enabling git SSH push/pull access immediately).
4. **NordVPN**: Triggers interactive login to enable VPN connectivity.
5. **Wallpapers**: Automatically clones the private wallpaper repository (`private-wallpaper`) via SSH, or falls back gracefully to the public wallpaper collection:
   - **Public Wallpapers**: Available at [GitLab Wallpaper](https://gitlab.com/kylekwong/Wallpaper) (`git clone https://gitlab.com/kylekwong/Wallpaper.git ~/Wallpaper`).
   - **Private Wallpapers**: Alternatively clone manually via `git clone git@gitlab.com:kylekwong/private-wallpaper.git ~/Wallpaper`.
   - **Wallpaper Picker**: Place custom images into `~/Wallpaper/` and launch the picker with `SUPER + Space`.

## Fleet Rekeying & Secret Propagation

Because secrets are encrypted with public keys in `secrets/keys.nix`, the new machine's keys must be pushed to git, rekeyed from an existing authorized machine, and pulled back down:

### 1. On the New Machine:
Commit and push the generated `hardware-configuration.nix` and updated `secrets/keys.nix`:
```bash
git lazy "feat(<host_name>): add host keys and hardware configuration"
```

### 2. On an Authorized Machine (e.g. `framework16`):
Pull the changes, re-encrypt the agenix secrets with the new host's public key, and push:
```bash
git pull
cd secrets
agenix --rekey
git lazy "chore(secrets): rekey secrets for <host_name>"
```

### 3. Back on the New Machine:
Pull the re-encrypted secret files and trigger a system rebuild:
```bash
git pull
nrs
```

Your new machine is now fully provisioned and synchronized with the fleet.
