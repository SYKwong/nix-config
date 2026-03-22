# nix-config
## How to use

`sudo su`
`echo "your-super-secure-password" > /tmp/secret.key`
`cd nix-config`

### For framework16
`sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./hosts/framework16/framework16-luks.nix`

Since `hardware-configuration.nix` is for my machine, you should run   
`nixos-generate-config --no-filesystems --root /mnt`  
to get your `hardware-configuration.nix`

`nixos-install --flakes .#framework16`

`inixos-enter --root /mnt -c 'your-password'`
`reboot`

`sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/<device>`

