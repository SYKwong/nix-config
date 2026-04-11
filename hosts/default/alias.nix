{ hostname, ... }:

{
  home.shellAliases = {
    npull = "git pull -C ~/nix-config";
    nrs = "sudo nixos-rebuild switch --flake ~/nix-config/#${hostname}";
    nrb = "sudo nixos-rebuild boot --flake ~/nix-config/#${hostname}";
  };
}
