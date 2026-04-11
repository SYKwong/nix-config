{ hostname, ... }:

{
  home.shellAliases = {
    npull = "git -C ~/nix-config pull";
    nrs = "sudo nixos-rebuild switch --flake ~/nix-config/#${hostname}";
    nrb = "sudo nixos-rebuild boot --flake ~/nix-config/#${hostname}";
  };
}
