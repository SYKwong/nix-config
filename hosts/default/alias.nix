{ hostname, ... }:

{
  home.shellAliases = {
    npull = "git -C ~/nix-config pull";
    nrs = "nixos-rebuild switch --flake ~/nix-config/#${hostname}";
    nrb = "nixos-rebuild boot --flake ~/nix-config/#${hostname}";
    
    n = "nvim"; 
  };
}
