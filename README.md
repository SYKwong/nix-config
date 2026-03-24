# nix-config
## How to use

```
sudo su  
echo "your-super-secure-password" > /tmp/secret.key  
cd nix-config  
```


### For framework16
Since `hardware-configuration.nix` is for my machine, you should run   
`nixos-generate-config --no-filesystems --root /mnt`  
to get your `hardware-configuration.nix` and replace the one in the repo with it.  
Also because I wrote my `framework16-luks.nix`, which is a [disko](https://github.com/nix-community/disko) file, to use a specific drive on my system, you should change `/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_4TB_S7KGNJ0W903445L` to the drive you want to install NixOS on.

```
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./hosts/framework16/framework16-luks.nix --yes-wipe-all-disks  
nixos-install --flake .#framework16  
nixos-enter --root /mnt -c 'passwd "your_user_name"'
reboot
```

After reboot
```
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-partlabel/disk-main-luks
```

