{ hostname, ... }:

{
  home.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake ~/nix-config/#${hostname}";
    nrb = "sudo nixos-rebuild boot --flake ~/nix-config/#${hostname}";
  };
}
