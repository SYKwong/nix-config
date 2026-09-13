# HTPC Installation & Finalization Checklist

Checklist and exact commands to run for provisioning `mini-pc-k8`.

---

## 1. On Live USB (`mini-pc-k8`)

- [ ] **Connect to Network**: Ensure Ethernet cable is connected.
- [ ] **Clone and Switch to Branch**:
  ```bash
  git clone https://gitlab.com/kylekwong/nix-config.git ~/nix-config
  cd ~/nix-config
  git checkout htpc
  ```
- [ ] **Verify Target Drive**:
  ```bash
  ls -l /dev/disk/by-id/ | grep nvme-CT1000P3PSSD8_25164F8237A7
  ```
- [ ] **Run Installer**:
  ```bash
  sudo ./install.sh "mini-pc-k8" "<user_password>"
  ```
  *(The system will partition the disk, generate hardware configuration, install NixOS, and reboot)*

---

## 2. On Installed Host (`mini-pc-k8`) - First Boot

- [ ] **Run Post-Install Script (Hands-Off)**:
  ```bash
  cd ~/nix-config
  ./post-install.sh
  ```
  *(Automated & hands-off: switches git remote to SSH, generates host & user SSH keys, enrolls TPM2 if LUKS is present, and registers keys in `secrets/keys.nix`)*

- [ ] **Authenticate Services (Optional Step)**:
  ```bash
  ./post-install.sh --auth-only
  ```
  *(Interactively authenticates and uploads SSH keys to GitLab and GitHub, logs into NordVPN, and clones wallpaper repo; or run `./post-install.sh --auth`)*

- [ ] **Commit and Push Hardware Config & Host Keys**:
  ```bash
  git lazy "feat(mini-pc-k8): add host keys and hardware configuration"
  ```

---

## 3. On Authorized Host (`framework16`)

- [ ] **Pull Keys and Rekey Secrets**:
  ```bash
  cd ~/nix-config
  git pull
  cd secrets
  agenix --rekey
  cd ..
  git lazy "chore(secrets): rekey secrets for mini-pc-k8"
  ```

---

## 4. On Installed Host (`mini-pc-k8`) - Final Activation

- [ ] **Pull Secrets & Rebuild**:
  ```bash
  cd ~/nix-config
  git pull
  rebuild
  ```

- [ ] **Verify Active Secrets**:
  ```bash
  ls -la /run/agenix
  ```
