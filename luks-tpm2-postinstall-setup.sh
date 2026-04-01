#!/usr/bin/env bash

sudo sbctl enroll-keys --microsoft
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-partlabel/disk-main-luks
echo "reboot and enable secure boot in bios"
