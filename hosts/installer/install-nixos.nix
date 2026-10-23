{ pkgs }:

pkgs.writeShellApplication {
  name = "install-nixos";

  runtimeInputs = with pkgs; [
    coreutils
    efibootmgr
    git
    gnugrep
    nixos-install-tools
    openssh
    systemd
  ];

  text = ''
    trap 'rm -f /tmp/secret.key' EXIT
    export NIX_CONFIG="experimental-features = nix-command flakes"

    if [ "$#" -lt 2 ]; then
      echo "Error: Missing required arguments."
      echo "Usage: sudo install-nixos \"<host_name>\" \"<user_password>\" [\"<luks_password>\"]"
      echo "Note: Always wrap arguments in double quotes to handle special characters."
      exit 1
    fi

    if [ "$EUID" -ne 0 ]; then
      echo "Please run as root (use sudo)."
      exit 1
    fi

    host_name="$1"
    user_password="$2"
    luks_password="''${3:-}"
    user_name=""

    find_repo_dir() {
      if [ -n "''${NIX_CONFIG_DIR:-}" ] && [ -f "''${NIX_CONFIG_DIR}/flake.nix" ]; then
        echo "$NIX_CONFIG_DIR"
        return 0
      fi

      if git_root=$(git rev-parse --show-toplevel 2>/dev/null); then
        if [ -f "$git_root/flake.nix" ] && [ -d "$git_root/hosts" ]; then
          echo "$git_root"
          return 0
        fi
      fi

      local cur="$PWD"
      while [ "$cur" != "/" ]; do
        if [ -f "$cur/flake.nix" ] && [ -d "$cur/hosts" ]; then
          echo "$cur"
          return 0
        fi
        cur=$(dirname "$cur")
      done

      for candidate in \
        "/root/nix-config" \
        "/home/nixos/nix-config" \
        "''${HOME:-}/nix-config" \
        "/mnt/etc/nixos"; do
        if [ -f "$candidate/flake.nix" ] && [ -d "$candidate/hosts" ]; then
          echo "$candidate"
          return 0
        fi
      done

      return 1
    }

    if ! REPO_DIR=$(find_repo_dir); then
      echo "Error: Cannot locate nix-config repository." >&2
      echo "Please run from within the repository or set NIX_CONFIG_DIR." >&2
      exit 1
    fi

    echo "Using repository at: $REPO_DIR"
    cd "$REPO_DIR"

    update_repository_from_remote() {
      if ! git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 0
      fi

      local remote="origin"
      if ! git -C "$REPO_DIR" remote get-url "$remote" >/dev/null 2>&1; then
        echo "Error: Git remote '$remote' is not configured." >&2
        exit 1
      fi

      local current_branch
      current_branch=$(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")

      echo "Pulling latest commits from $remote/$current_branch..."
      if ! git -C "$REPO_DIR" pull "$remote" "$current_branch"; then
        echo "Error: Failed to pull latest commits from $remote/$current_branch." >&2
        echo "An active internet connection is required to fetch repository updates and build the NixOS system closure." >&2
        exit 1
      fi
      echo "==> [OK] Successfully updated repository to latest commit ($(git -C "$REPO_DIR" rev-parse --short HEAD))."
    }

    update_repository_from_remote

    if [ ! -f "$REPO_DIR/hosts/''${host_name}/disko.nix" ]; then
      echo "Error: $REPO_DIR/hosts/''${host_name}/disko.nix does not exist."
      exit 1
    fi

    if fetched_user=$(nix eval --raw "$REPO_DIR#lib.hostInfo.''${host_name}.username" 2>/dev/null); then
      echo "Found user: $fetched_user"
      user_name=$fetched_user
    else
      echo "Error: Hostname '$host_name' or username attribute not found in flake."
      exit 1
    fi

    set_up_full_disk_encryption() {
      if [ -n "$luks_password" ]; then
        echo "LUKS password provided. Creating secret key..."
        echo "$luks_password" >/tmp/secret.key
      else
        echo "No LUKS password provided. Skipping encryption setup..."
      fi
    }

    disko_partition() {
      echo "Using $REPO_DIR/hosts/''${host_name}/disko.nix to partition your drive"
      nix run github:nix-community/disko/latest -- \
        --mode destroy,format,mount "$REPO_DIR/hosts/''${host_name}/disko.nix" --yes-wipe-all-disks
    }

    generate_hardware_configuration() {
      local hw_file="$REPO_DIR/hosts/''${host_name}/hardware-configuration.nix"

      if [ ! -s "$hw_file" ] || ! grep -q "not-detected.nix" "$hw_file"; then
        echo "Stub hardware configuration detected for ''${host_name}. Generating..."
        nixos-generate-config --no-filesystems --dir "$REPO_DIR/hosts/''${host_name}"
        rm -f "$REPO_DIR/hosts/''${host_name}/configuration.nix"
        git -C "$REPO_DIR" add "$hw_file" 2>/dev/null || true
        echo "Hardware configuration successfully generated."
      else
        echo "Using existing hardware configuration for ''${host_name}."
      fi
    }

    cleanup_stale_boot_entries() {
      local OLD_ENTRIES
      OLD_ENTRIES=$( (efibootmgr | grep "Linux Boot Manager" || true) | cut -d' ' -f1 | cut -d't' -f2 | tr -d '*')

      for entry in $OLD_ENTRIES; do
        echo "Cleaning up stale boot entry: Boot''${entry}"
        efibootmgr -b "$entry" -B
      done
    }

    install_nixos() {
      echo "Starting NixOS installation..."
      nixos-install --no-root-password --flake "$REPO_DIR#''${host_name}"

      echo "Setting password for user: $user_name"
      echo "root:$user_password" | nixos-enter --root /mnt -c "chpasswd"
      echo "$user_name:$user_password" | nixos-enter --root /mnt -c "chpasswd"
    }

    copy_config_to_host() {
      local config_dir="home/''${user_name}/nix-config"
      echo "Copying flake configuration to /mnt/$config_dir..."
      mkdir -p "/mnt/$config_dir"
      cp -r "$REPO_DIR/." "/mnt/$config_dir"
      nixos-enter --root /mnt -c "chown -R $user_name:users /$config_dir"
      echo "Flake successfully copied."
    }

    set_up_full_disk_encryption
    disko_partition
    generate_hardware_configuration
    cleanup_stale_boot_entries
    install_nixos
    copy_config_to_host

    echo "Installation finished! Rebooting..."
    sleep 5
    reboot
  '';
}
