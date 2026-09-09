{
  pkgs,
  hostname,
  config_path,
  ...
}:

pkgs.writeShellApplication {
  name = "rebuild";

  runtimeInputs = [
    pkgs.binutils
    pkgs.coreutils
    pkgs.gawk
    pkgs.git
    pkgs.gnugrep
    pkgs.nh
    pkgs.systemd
  ];

  text = ''
    if [ "''${EUID}" -ne 0 ]; then
      exec sudo /run/current-system/sw/bin/rebuild "$@"
    fi

    if [ -t 1 ]; then
      BOLD="\033[1m"
      GREEN="\033[1;32m"
      BLUE="\033[1;34m"
      YELLOW="\033[1;33m"
      RED="\033[1;31m"
      RESET="\033[0m"
    else
      BOLD=""
      GREEN=""
      BLUE=""
      YELLOW=""
      RED=""
      RESET=""
    fi

    log_info() {
      printf "%b==> [INFO]%b %s\n" "$BLUE" "$RESET" "$*"
    }
    log_success() {
      printf "%b==> [OK]%b %s\n" "$GREEN" "$RESET" "$*"
    }
    log_warn() {
      printf "%b==> [WARN]%b %s\n" "$YELLOW" "$RESET" "$*"
    }
    log_error() {
      printf "%b==> [ERROR]%b %s\n" "$RED" "$RESET" "$*"
    }

    REPO="${config_path}"
    HOSTNAME="${hostname}"

    log_info "Building configuration and staging boot entry with nh..."
    if ! sudo nh os boot "$REPO" -H "$HOSTNAME" -e passwordless --bypass-root-check; then
      log_error "Failed to build configuration."
      exit 1
    fi

    log_success "Boot entry created successfully."

    log_info "Activating configuration live..."
    if /nix/var/nix/profiles/system/bin/switch-to-configuration switch; then
      log_success "Live switch succeeded."
    else
      log_warn "Live switch failed. Boot entry is saved and changes will apply on next reboot."
    fi

    CONFIG_KERNEL=$(strings /nix/var/nix/profiles/system/kernel | grep -E '^[0-9]+\.[0-9]+' | head -n 1 | awk '{print $1}')
    RUNNING_KERNEL=$(uname -r | awk '{print $1}')

    if [ "$RUNNING_KERNEL" != "$CONFIG_KERNEL" ]; then
      echo ""
      printf "%b=======================================================%b\n" "$YELLOW" "$RESET"
      printf "%b==> [NOTICE] Pending reboot to apply kernel update%b\n" "$YELLOW" "$RESET"
      printf "    Running kernel: %b%s%b\n" "$BOLD" "$RUNNING_KERNEL" "$RESET"
      printf "    Staged kernel:  %b%s%b\n" "$BOLD" "$CONFIG_KERNEL" "$RESET"
      printf "%b=======================================================%b\n" "$YELLOW" "$RESET"
      echo ""

      printf "%bWould you like to reboot now to apply the changes? (y/N): %b" "$BOLD" "$RESET"
      read -r reply
      if [[ "$reply" =~ ^[Yy]$ ]]; then
        reboot
      fi
    fi
  '';
}
