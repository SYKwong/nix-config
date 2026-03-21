# nix-config
`sudo su`
`echo "your-super-secure-password" > /tmp/secret.key`

### For framework16
`sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./hosts/framework16/framework16-luks.nix``
`nixos-install --flakes .#fraamework16`

