{ hostname, ... }:

{
  home.shellAliases = {
    npull = "git -C ~/nix-config pull";
    nrs = "rebuild";
    nrb = "sudo nixos-rebuild boot --flake ~/nix-config/#${hostname}";

    n = "nvim";
  };
}
