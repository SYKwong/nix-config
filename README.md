# nix-config  

## How to use  

### Step 0 on framework16  

1. Boot to BIOS
2. Administer Secure Boot
3. Erase all Secure Boot Settings
  
``` bash
sudo su  
```

### For framework16

`hardware-configuration.nix` is for my machine.  
You should run `nixos-generate-config --no-filesystems --root /mnt`  
to get your `hardware-configuration.nix`, and replace the one in the repo with it.  
Also because I wrote my`disko.nix`, which is a [disko](https://github.com/nix-community/disko) file, to use a specific drive on my system, you should change `/dev/disk/by-id/nvme-samsung_ssd_990_pro_4tb_s7kgnj0w903445l` to the drive you want to install NixOS on.  
You should also change the swap size to be 2 to 4GB + your ram capacity.

``` bash
echo "your-super-secure-password" > /tmp/secret.key  
cd nix-config  
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./hosts/framework16/disko.nix --yes-wipe-all-disks  
nix-shell -p sbctl
mkdir -p /mnt/var/lib/sbctl
sbctl create-keys --export /mnt/var/lib/sbctl/keys
nixos-install --flake .#framework16  
nixos-enter --root /mnt -c 'passwd "your_user_name"'
reboot
```

After reboot

```bash
sudo sbctl enroll-keys --microsoft
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-partlabel/disk-main-luks
reboot and enable secure boot in BIOS
if LUKS is not auto unlocking, enroll again
```
