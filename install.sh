#!/usr/bin/env bash

set -euo pipefail
trap 'rm -f /tmp/secret.key' EXIT
export NIX_CONFIG="experimental-features = nix-command flakes" 

# Checks if the user provided at least host_name and user_password
if [ "$#" -lt 2 ]; then
  echo "Error: Missing required arguments."
  echo "Usage: sudo $0 \"<host_name>\" \"<user_password>\" [\"<luks_password>\"]"
  echo "Note: Always wrap arguments in double quotes to handle special characters."
  exit 1
fi

# Root Check
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)."
  exit 1
fi

host_name="$1"
user_password="$2"
luks_password="${3:-}"
user_name=""

# Disko File Validation
if [ ! -f "./hosts/${host_name}/disko.nix" ]; then
  echo "Error: ./hosts/${host_name}/disko.nix does not exist."
  exit 1
fi 

# Fetch username from the Flake
if fetched_user=$(nix eval --raw ".#hostInfo.${host_name}.username" 2>/dev/null); then
    echo "Found user: $fetched_user"
    user_name=$fetched_user
else
    echo "Error: Hostname '${host_name}' or username attribute not found in flake."
    exit 1
fi

disko_partition(){
  echo "Using ./hosts/${host_name}/disko.nix to partition your drive"
  nix run github:nix-community/disko/latest -- \
      --mode destroy,format,mount "./hosts/${host_name}/disko.nix" --yes-wipe-all-disks
}

set_up_partitions() {
  if [ -n "$luks_password" ]; then
    echo "LUKS password provided. Creating secret key..."
    echo "$luks_password" > /tmp/secret.key
    disko_partition
    mkdir -p /mnt/var/lib/sbctl/keys
    nix run nixpkgs#sbctl -- create-keys --export /mnt/var/lib/sbctl/keys
  else
    echo "No LUKS password provided. Skipping encryption setup..."
    disko_partition
  fi
}

install_nixos(){
  echo "Starting NixOS installation..."
  nixos-install --flake ".#${host_name}"  
 
  echo "Setting password for user: $user_name"
  echo "$user_name:$user_password" | nixos-enter --root /mnt -c "chpasswd"
}

copy_config_to_host(){
  local config_dir="home/$user_name/nix-config"
  echo "Copying flake configuration to /mnt/$config_dir..."
  mkdir -p "/mnt/$config_dir"
  cp -r . "/mnt/$config_dir"
  nixos-enter --root /mnt -c "chown -R $user_name:users /$config_dir"
  echo "Flake successfully copied."
}

set_up_partitions
install_nixos
copy_config_to_host
echo "Installation finished! Rebooting..."
sleep 5
reboot

