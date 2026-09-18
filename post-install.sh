#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYS_FILE="$SCRIPT_DIR/secrets/keys.nix"
HOST_IDENTIFIER=""
HOST_KEY=""
USER_KEY=""
WITH_AUTH=false
AUTH_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --auth-only|-A|auth-only)
      AUTH_ONLY=true
      WITH_AUTH=true
      ;;
    --auth|-a|auth)
      WITH_AUTH=true
      ;;
    --help|-h)
      echo "Usage: $0 [--auth] [--auth-only]"
      echo "  --auth, -a, auth           Run full post-install setup and authenticate services"
      echo "  --auth-only, -A, auth-only Run only service authentication (GitLab, GitHub, NordVPN, Wallpaper)"
      exit 0
      ;;
  esac
done

determine_host_identifier() {
  if [ -f /etc/hostname ]; then
    HOST_IDENTIFIER=$(tr -d '[:space:]' < /etc/hostname)
  else
    HOST_IDENTIFIER=$(hostname -s 2>/dev/null || hostname)
  fi

  if [ -z "$HOST_IDENTIFIER" ]; then
    echo "Error: Host name could not be determined from /etc/hostname or hostname."
    exit 1
  fi
  echo "Setting up SSH keys for host: $HOST_IDENTIFIER"
}

enroll_tpm2_luks() {
  local luks_device="/dev/disk/by-partlabel/disk-main-luks"

  if [ ! -b "$luks_device" ]; then
    return 0
  fi

  if [ ! -e /dev/tpmrm0 ] && [ ! -e /dev/tpm0 ]; then
    echo "Notice: LUKS volume found at $luks_device, but no TPM2 device detected. Skipping TPM2 enrollment."
    return 0
  fi

  if sudo cryptsetup luksDump "$luks_device" 2>/dev/null | grep -q "systemd-tpm2"; then
    echo "TPM2 is already enrolled for $luks_device. Skipping..."
    return 0
  fi

  if ! bootctl status --no-pager 2>/dev/null | grep -q "Secure Boot: enabled"; then
    echo "Warning: Secure Boot is not active. Sealing against PCR 7 requires Secure Boot enabled in BIOS."
  fi

  echo ""
  echo "LUKS partition detected at $luks_device."
  echo "Enrolling TPM2 for automatic unlocking (PCR 7)..."
  sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 "$luks_device"
}

ensure_git_ssh_remote() {
  local remote_url
  remote_url=$(git -C "$SCRIPT_DIR" remote get-url origin 2>/dev/null || true)

  if [[ "$remote_url" =~ ^https://([^/]+)/(.+)$ ]]; then
    local host="${BASH_REMATCH[1]}"
    local repo_path="${BASH_REMATCH[2]}"
    local ssh_url="git@${host}:${repo_path}"
    echo "Updating git remote origin from HTTPS to SSH ($ssh_url)..."
    git -C "$SCRIPT_DIR" remote set-url origin "$ssh_url"
  fi
}

ensure_host_ssh_key() {
  local host_key_file="/etc/ssh/ssh_host_ed25519_key.pub"
  if [ ! -f "$host_key_file" ]; then
    echo "Host SSH key not found. Generating /etc/ssh/ssh_host_ed25519_key..."
    sudo ssh-keygen -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key
  fi
  HOST_KEY=$(awk '{print $1 " " $2}' "$host_key_file")
  echo "Host public key: $HOST_KEY"
}

ensure_user_ssh_key() {
  local user_key_file="$HOME/.ssh/id_ed25519.pub"
  if [ ! -f "$user_key_file" ]; then
    echo "User SSH key not found. Generating $HOME/.ssh/id_ed25519..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519"
  fi
  USER_KEY=$(awk '{print $1 " " $2}' "$user_key_file")
  echo "User public key: $USER_KEY"
}

update_keys_nix() {
  if grep -q "\"$HOST_IDENTIFIER\" = " "$KEYS_FILE" || grep -q " $HOST_IDENTIFIER = " "$KEYS_FILE"; then
    echo "Keys for '$HOST_IDENTIFIER' already exist in $KEYS_FILE."
    return 0
  fi

  echo "Adding '$HOST_IDENTIFIER' keys to $KEYS_FILE..."
  awk -v name="$HOST_IDENTIFIER" -v ukey="$USER_KEY" -v hkey="$HOST_KEY" '
    /users = \{/ { in_users=1 }
    in_users && /^[[:space:]]*\};/ {
      print "    \"" name "\" = \"" ukey "\";"
      in_users=0
    }
    /systems = \{/ { in_systems=1 }
    in_systems && /^[[:space:]]*\};/ {
      print "    \"" name "\" = \"" hkey "\";"
      in_systems=0
    }
    { print }
  ' "$KEYS_FILE" > "${KEYS_FILE}.tmp" && mv "${KEYS_FILE}.tmp" "$KEYS_FILE"

  nix fmt "$KEYS_FILE" 2>/dev/null || true
  echo "Successfully updated $KEYS_FILE."
}

rekey_secrets() {
  echo ""
  echo "Attempting to rekey secrets with agenix..."
  if (cd "$SCRIPT_DIR/secrets" && agenix --rekey 2>/dev/null); then
    echo "==> [OK] Secrets rekeyed successfully!"
  else
    echo "==> [NOTICE] Rekey skipped or failed (expected on a new machine that does not possess an authorized private key yet)."
    echo "    Next steps:"
    echo "    1. Commit and push the updated secrets/keys.nix."
    echo "    2. On an authorized machine (e.g. fw16), run: cd secrets && agenix --rekey"
    echo "    3. Commit and push the re-encrypted .age files."
    echo "    4. On this machine, pull and rebuild (nrs) to activate secrets."
  fi
}

clone_wallpaper_repo() {
  local target_dir="$HOME/Wallpaper"

  echo ""
  echo "--- Wallpaper Repository ---"
  if [ -d "$target_dir/.git" ]; then
    echo "Wallpaper repository already exists at $target_dir. Skipping clone."
    return 0
  fi

  echo "Cloning private wallpaper repository via SSH..."
  if ! git clone "git@gitlab.com:kylekwong/private-wallpaper.git" "$target_dir"; then
    echo "==> [NOTICE] Failed to clone private wallpaper repository."
    echo "    Falling back to public wallpaper repository..."
    rm -rf "$target_dir"
    if ! git clone "https://gitlab.com/kylekwong/Wallpaper.git" "$target_dir"; then
      echo "==> [WARN] Failed to clone public wallpaper repository."
      echo "    You can clone it manually later:"
      echo "    git clone https://gitlab.com/kylekwong/Wallpaper.git ~/Wallpaper"
    else
      echo "Public wallpaper repository successfully cloned to $target_dir."
    fi
  else
    echo "Private wallpaper repository successfully cloned to $target_dir."
  fi
}

authenticate_gitlab() {
  local user_key_file="$HOME/.ssh/id_ed25519.pub"
  local key_title="$HOST_IDENTIFIER"

  echo ""
  echo "--- GitLab Authentication (glab) ---"
  if glab auth status >/dev/null 2>&1; then
    echo "GitLab is already authenticated."
  else
    echo "Authenticating with GitLab..."
    if ! glab auth login --hostname gitlab.com --web --git-protocol ssh; then
      echo "GitLab authentication was skipped or failed."
      echo "==> [ACTION REQUIRED] Add this user public key to GitLab manually to allow git push:"
      echo "    https://gitlab.com/-/user_settings/ssh_keys"
      return 0
    fi
  fi

  echo "Ensuring SSH key is uploaded to GitLab as '$key_title'..."
  local glab_output
  if glab_output=$(glab ssh-key add "$user_key_file" --title "$key_title" 2>&1); then
    echo "==> [OK] SSH key successfully added to GitLab!"
  elif echo "$glab_output" | grep -qi "already been taken"; then
    echo "==> [OK] SSH key already registered on GitLab."
  else
    echo "==> [WARN] Failed to add SSH key to GitLab:"
    echo "    $glab_output"
  fi

  echo "Verifying SSH connection to GitLab..."
  ssh -T -o StrictHostKeyChecking=accept-new git@gitlab.com 2>&1 || true
}

authenticate_github() {
  local user_key_file="$HOME/.ssh/id_ed25519.pub"
  local key_title="$HOST_IDENTIFIER"

  echo ""
  echo "--- GitHub Authentication (gh) ---"
  if gh auth status >/dev/null 2>&1; then
    echo "GitHub is already authenticated."
    if ! gh auth status 2>&1 | grep -q "admin:public_key"; then
      echo "Existing token lacks 'admin:public_key' scope. Refreshing credentials..."
      gh auth refresh -h github.com -s admin:public_key
    fi
  else
    echo "Authenticating with GitHub..."
    if ! gh auth login --hostname github.com --web --git-protocol ssh --skip-ssh-key -s admin:public_key; then
      echo "GitHub authentication was skipped or failed."
      return 0
    fi
  fi

  echo "Ensuring SSH key is uploaded to GitHub as '$key_title'..."
  local gh_output
  if gh_output=$(gh ssh-key add "$user_key_file" --title "$key_title" 2>&1); then
    echo "==> [OK] $gh_output"
  else
    echo "==> [WARN] Failed to add SSH key to GitHub:"
    echo "    $gh_output"
  fi

  echo "Verifying SSH connection to GitHub..."
  ssh -T -o StrictHostKeyChecking=accept-new git@github.com 2>&1 || true
}

authenticate_nordvpn() {
  echo ""
  echo "--- NordVPN Authentication ---"
  if nordvpn account 2>/dev/null | grep -qi "Email address"; then
    echo "NordVPN is already logged in."
  else
    echo "Opening browser to log into NordVPN..."
    nordvpn login || true

    echo ""
    read -r -p "Complete login in your browser, then press [Enter] to continue..."

    if ! nordvpn account 2>/dev/null | grep -qi "Email address"; then
      echo "Notice: NordVPN account does not appear logged in yet."
      return 0
    fi
    echo "==> [OK] NordVPN login successful!"
  fi

  echo "Configuring NordVPN LAN discovery..."
  nordvpn set lan-discovery on || true
}

authenticate_services() {
  echo ""
  echo "=========================================="
  echo "         Service Authentication           "
  echo "=========================================="
  authenticate_gitlab
  authenticate_github
  authenticate_nordvpn
  clone_wallpaper_repo
}

print_reminders() {
  echo ""
  echo "=========================================="
  echo "    Post-Install Completed (Hands-Off)    "
  echo "=========================================="
  echo ""
  echo "User SSH public key ($HOME/.ssh/id_ed25519.pub):"
  echo "  $USER_KEY"
  echo ""
  if [ "$WITH_AUTH" = false ]; then
    echo "Optional service authentication:"
    echo "  Run '$0 --auth-only' to interactively authenticate services,"
    echo "  or authenticate individually whenever you are ready:"
    echo "    - GitLab:    glab auth login --hostname gitlab.com --web --git-protocol ssh"
    echo "                 (or add key at https://gitlab.com/-/user_settings/ssh_keys)"
    echo "    - GitHub:    gh auth login --hostname github.com --web --git-protocol ssh -s admin:public_key"
    echo "    - NordVPN:   nordvpn login"
    echo "    - Wallpaper: git clone git@gitlab.com:kylekwong/private-wallpaper.git ~/Wallpaper (or public: https://gitlab.com/kylekwong/Wallpaper.git)"
    echo ""
  fi
  echo "Next steps:"
  echo "  git lazy \"feat($HOST_IDENTIFIER): add host keys and hardware configuration\""
}

determine_host_identifier
ensure_user_ssh_key
ensure_git_ssh_remote

if [ "$AUTH_ONLY" = true ]; then
  authenticate_services
  echo ""
  echo "=========================================="
  echo "     Authentication Completed Successfully"
  echo "=========================================="
  exit 0
fi

enroll_tpm2_luks
ensure_host_ssh_key
update_keys_nix
rekey_secrets

if [ "$WITH_AUTH" = true ]; then
  authenticate_services
fi

print_reminders
