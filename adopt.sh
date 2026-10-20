#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_usage() {
  cat <<EOF
Usage: $0 <hostname> <username> [OPTIONS]

Sanitize the repository for adoption and scaffold a clean host configuration.

Arguments:
  <hostname>               Target hostname for the machine (e.g. workstation, thinkpad)
  <username>               Primary user account name (e.g. alice, bob)

Options:
  --laptop                 Include laptop-specific modules (power management, sleep hooks)
  --desktop                Include desktop-specific modules (default)
  --luks                   Enable LUKS disk encryption with TPM2 auto-unlock in disko.nix
  --disk <device_path>     Set persistent disk device path
                           (default: /dev/disk/by-id/REPLACE_WITH_YOUR_DISK_ID)
  --remote <git_url>       Set git remote origin to your fork URL
  --keep-reference         Move author's host profiles to hosts/_reference/ instead of deleting
  -h, --help               Show this help message

Example:
  $0 my-laptop alice --laptop --luks --remote https://github.com/alice/nix-config.git
EOF
}

if [ "$#" -lt 2 ]; then
  print_usage
  exit 1
fi

host_name="$1"
user_name="$2"
shift 2

is_laptop=false
is_luks=false
keep_reference=false
disk_device="/dev/disk/by-id/REPLACE_WITH_YOUR_DISK_ID"
remote_url=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --laptop)
      is_laptop=true
      shift
      ;;
    --desktop)
      is_laptop=false
      shift
      ;;
    --luks)
      is_luks=true
      shift
      ;;
    --disk)
      if [ -z "${2:-}" ]; then
        echo "Error: --disk requires a device path argument."
        exit 1
      fi
      disk_device="$2"
      shift 2
      ;;
    --remote)
      if [ -z "${2:-}" ]; then
        echo "Error: --remote requires a git URL argument."
        exit 1
      fi
      remote_url="$2"
      shift 2
      ;;
    --keep-reference)
      keep_reference=true
      shift
      ;;
    -h | --help)
      print_usage
      exit 0
      ;;
    *)
      echo "Error: Unknown option '$1'"
      print_usage
      exit 1
      ;;
  esac
done

if [[ ! $host_name =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Error: Invalid hostname '$host_name'. Only alphanumeric characters, dashes, and underscores are allowed."
  exit 1
fi

if [[ ! $user_name =~ ^[a-z_][a-z0-9_-]*$ ]]; then
  echo "Error: Invalid username '$user_name'. Must start with a lowercase letter or underscore, followed by lowercase alphanumeric characters, dashes, or underscores."
  exit 1
fi

purge_secrets() {
  echo "==> Purging inaccessible encrypted secrets and keys..."
  rm -f "$SCRIPT_DIR"/secrets/*.age

  cat <<'EOF' >"$SCRIPT_DIR/modules/secrets/default.nix"
{ ... }:

{
  age.secrets = { };
}
EOF

  cat <<'EOF' >"$SCRIPT_DIR/secrets/keys.nix"
{
  users = { };
  systems = { };
}
EOF

  cat <<'EOF' >"$SCRIPT_DIR/secrets/secrets.nix"
let
  keys = import ./keys.nix;
  allKeys = (builtins.attrValues (keys.users or { })) ++ (builtins.attrValues (keys.systems or { }));
in
{ }
EOF
}

purge_network_shares() {
  echo "==> Removing author's private NAS network shares..."
  rm -f "$SCRIPT_DIR/modules/desktop/networkshare.nix" "$SCRIPT_DIR/modules/laptop/networkshare.nix"

  cat <<'EOF' >"$SCRIPT_DIR/modules/desktop/default.nix"
{
  imports = [
    ./wireless-config.nix
  ];
}
EOF

  cat <<'EOF' >"$SCRIPT_DIR/modules/laptop/default.nix"
{
  imports = [
    ./sleep.nix
  ];
}
EOF
}

sanitize_opencode() {
  local opencode_file="$SCRIPT_DIR/home/cli/opencode.nix"
  if [ -f "$opencode_file" ]; then
    echo "==> Sanitizing OpenCode config (removing Cloudflare Workers AI provider)..."
    cat <<'EOF' >"$opencode_file"
{
  stylix.targets.opencode.enable = true;

  programs.opencode = {
    enable = true;
    settings = {
      "permission" = {
        "read" = "allow";
        "list" = "allow";
        "glob" = "allow";
        "grep" = "allow";
        "edit" = "allow";
        "write" = "allow";
        "bash" = {
          "*" = "ask";
          "git status *" = "allow";
          "git diff *" = "allow";
          "docker *" = "ask";
          "curl *" = "ask";
          "wget *" = "ask";
          "ssh *" = "deny";
          "sudo *" = "deny";
          "rm *" = "ask";
          "git commit *" = "deny";
          "git push *" = "deny";
          "git reset --hard *" = "deny";
          "git clean *" = "deny";
        };
      };
      provider = {
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama (local)";
          options.baseURL = "http://localhost:11434/v1";
          models = {
            "qwen3-coder:30b".name = "Qwen3 Coder 30B";
          };
        };
      };
    };
  };
}
EOF
  fi
}

scaffold_host() {
  if [ "$keep_reference" = true ]; then
    echo "==> Preserving author's host directories under hosts/_reference/..."
    local ref_dir="$SCRIPT_DIR/hosts/_reference"
    mkdir -p "$ref_dir"
    [ -d "$SCRIPT_DIR/hosts/framework16" ] && mv "$SCRIPT_DIR/hosts/framework16" "$ref_dir/"
    [ -d "$SCRIPT_DIR/hosts/mini-pc-k8" ] && mv "$SCRIPT_DIR/hosts/mini-pc-k8" "$ref_dir/"
  else
    echo "==> Removing author's host directories (framework16, mini-pc-k8)..."
    rm -rf "$SCRIPT_DIR/hosts/framework16" "$SCRIPT_DIR/hosts/mini-pc-k8"
  fi

  local target_host_dir="$SCRIPT_DIR/hosts/$host_name"
  echo "==> Scaffolding host directory at hosts/$host_name..."
  mkdir -p "$target_host_dir"

  touch "$target_host_dir/hardware-configuration.nix"

  cat <<'EOF' >"$target_host_dir/default.nix"
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];
}
EOF

  if [ "$is_luks" = true ]; then
    cat <<EOF >"$target_host_dir/disko.nix"
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "${disk_device}";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings = {
                  allowDiscards = true;
                };
                passwordFile = "/tmp/secret.key";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "16G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  security.tpm2.enable = true;

  boot.initrd.luks.devices."crypted".crypttabExtraOpts = [ "tpm2-device=auto" ];
}
EOF
  else
    cat <<EOF >"$target_host_dir/disko.nix"
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "${disk_device}";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/swap" = {
                    mountpoint = "/.swap";
                    swap.swapfile.size = "8G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };
}
EOF
  fi
}

configure_outputs() {
  echo "==> Updating outputs.nix with host '$host_name' (user: $user_name)..."
  local extra_module="./modules/desktop"
  if [ "$is_laptop" = true ]; then
    extra_module="./modules/laptop"
  fi

  cat <<EOF >"$SCRIPT_DIR/outputs.nix"
inputs:

let
  inherit (inputs) nixpkgs;

  hosts = {
    ${host_name} = {
      username = "${user_name}";

      extraModules = [
        ${extra_module}

        # Hardware tuning via nixos-hardware (https://github.com/NixOS/nixos-hardware)
        # 1. Exact model profile (e.g. inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen3)
        # 2. Or generic component profiles if no exact device profile exists:
        # inputs.nixos-hardware.nixosModules.common-cpu-amd
        # inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
        # inputs.nixos-hardware.nixosModules.common-gpu-amd
        # inputs.nixos-hardware.nixosModules.common-pc-ssd
      ];
    };
  };

in
{
  # Expose hosts for Bash
  lib.hostInfo = hosts;

  formatter.x86_64-linux =
    (inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.x86_64-linux ./treefmt)
    .config.build.wrapper;

  nixosConfigurations = nixpkgs.lib.mapAttrs (
    name: info:
    nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        inherit (info) username;
        hostname = name;
      };

      modules = [
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        inputs.stylix.nixosModules.stylix
        inputs.agenix.nixosModules.default

        ./modules/core

        ./modules/ai
        ./modules/gaming
        ./modules/home-manager
        ./modules/hyprland
        ./modules/input-method
        ./modules/secrets
        ./modules/shell-scripts
        ./modules/sunshine
        ./modules/vpn
        ./modules/wireless

        ./overlays

        ./hosts/\${name}

      ]
      ++ info.extraModules;
    }
  ) hosts;
}
EOF
}

configure_git_remote() {
  if [ -n "$remote_url" ]; then
    echo "==> Setting git remote origin to $remote_url..."
    git remote set-url origin "$remote_url" 2>/dev/null || git remote add origin "$remote_url" 2>/dev/null || true
  else
    local current_origin
    current_origin=$(git remote get-url origin 2>/dev/null || true)
    if [[ $current_origin =~ kylekwong/nix-config ]]; then
      echo ""
      echo "==> [NOTICE] Git remote 'origin' still points to the author's upstream repository:"
      echo "    $current_origin"
      echo "    Make sure to fork this repo and update origin to your fork so post-install.sh"
      echo "    can push your SSH keys and hardware configuration back to your fork:"
      echo "    git remote set-url origin git@<forge>:<your-username>/nix-config.git"
    fi
  fi
}

purge_secrets
purge_network_shares
sanitize_opencode
scaffold_host
configure_outputs
configure_git_remote

echo ""
echo "=========================================="
echo "    Adoption Setup Completed Successfully "
echo "=========================================="
echo "Host '$host_name' configured for user '$user_name'."
echo ""
echo "Important: Modules with Secret References"
echo "-----------------------------------------"
echo "The following user module references a runtime secret path that has been purged:"
echo "- home/cli/atuin.nix: References '/run/agenix/atuin-credentials'."
echo "  Auto-login will be skipped cleanly. Log into Atuin manually with 'atuin login'"
echo "  or rekey your own credentials with agenix."
echo ""
echo "Next steps:"
echo "1. Verify or edit your persistent drive ID in hosts/$host_name/disko.nix:"
echo '   device = "/dev/disk/by-id/..."'
echo "   (Discover your drive ID via: ls -l /dev/disk/by-id/)"
echo "2. (Optional) In outputs.nix, add nixos-hardware profiles matching your machine:"
echo "   - Exact OEM model: inputs.nixos-hardware.nixosModules.<model>"
echo "   - Or common components: common-cpu-amd/intel, common-gpu-amd/intel, common-pc-ssd"
echo "3. Commit and push your adopted setup to your fork:"
echo '   git add .'
echo "   git commit -m \"feat: adopt configuration for $host_name\""
echo "   git push origin <branch>"
echo "4. Boot your target machine into the NixOS Live USB, clone YOUR fork, and run:"
if [ "$is_luks" = true ]; then
  echo "   sudo ./install.sh \"$host_name\" \"<user_password>\" \"<luks_password>\""
else
  echo "   sudo ./install.sh \"$host_name\" \"<user_password>\""
fi
echo "5. After installation, reboot and run ./post-install.sh to enroll TPM2, convert your"
echo "   remote to SSH, and upload host SSH keys to your GitLab/GitHub account."
echo ""
