# nix-config  

# License

MIT-0  
You can use my code without any attribution, but I would appreciate if you do.
Please note that some part of this repo might be sublicensed to something else because I didn't write them.

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
to get your `hardware-configuration.nix` after disko,
and replace the one in the repo with it.  
Also because I wrote my`disko.nix`, which is a [disko](https://github.com/nix-community/disko) file, to use a specific drive on my system,i you should change `/dev/disk/by-id/nvme-samsung_ssd_990_pro_4tb_s7kgnj0w903445l` to the drive you want to install NixOS on.  
You should also change the swap size to be 2 to 4GB + your ram capacity.

``` bash
echo "your-super-secure-password" > /tmp/secret.key  
cd nix-config  
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./hosts/framework16/disko.nix --yes-wipe-all-disks  
nixos-install --flake .#framework16  
nixos-enter --root /mnt -c 'passwd "your_user_name"'
reboot
```

After reboot the system will show it is automatically enrolling a key.
Go to BIOS and enable Secure Boot.

```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-partlabel/disk-main-luks
if LUKS is not auto unlocking, enroll again
```

### Wallpaper
My list of wallpaper which was previously bundled in this repo was moved to its own repo to speed up fresh install and changing wallpaper will not create a meaningless change to the repo.
You can find them [here](https://gitlab.com/kylekwong/Wallpaper).  

If you want to use them, clone the repository to your home directory, aka `~/Wallpaper/`.  
If you want to use your own wallpaper, create your own `~/Wallpaper/`, put your wallpaper in, then start the wallpaper picker by using `SUPER + SPACE_BAR` -> `Wallpaper`.

### After BIOS Update
0. Please remember your LUKS password before you do a BIOS update  
1. NixOS will promopt you to enter your LUKS password after booting into it  
2. `sudo systemd-cryptenroll /dev/disk/by-partlabel/disk-main-luks --wipe-slot=tpm2`
3. `sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-partlabel/disk-main-luks`


### Formatting
Run `nix fmt`
