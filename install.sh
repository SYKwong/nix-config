#!/usr/bin/env bash

host_name=$1
user_name=""
luks-password=$2
config_dir=""

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)."
  exit 1
fi

sudo su

set_up_luks(){
 echo $luks-password > /tmp/secret.key
 nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./hosts/${host_name}/disko.nix --yes-wipe-all-disks
 nix-shell -p sbctl
 mkdir -p /mnt/var/lib/sbctl
 sbctl create-keys --export /mnt/var/lib/sbctl/keys
}

install_nixos(){
  nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./hosts/${host_name}/disko.nix --yes-wipe-all-disks  
  if [ -n "$2" ]; then
    set_up_luks
  fi
  nixos-install --flake .#{host_name}  
  user_name=$(nix eval --raw ".#hosts.$host_name.username")
  echo "Setting password for user: $user_name "
  nixos-enter --root /mnt -c 'passwd $user_name'
}

copy_config_to_host(){
  config_dir="home/$user_name/nix-config"
  mkdir -p /mnt/"$config_dir"
  cp -r . /mnt/"$config_dir"
  nixos-enter --root /mnt -c "chown -R $user_name:users /$config_dir"
  echo "Flake successfully copied."
}

reboot
