{ hostname, ... }:

{
  home.shellAliases = {
    npull = "git -C ~/nix-config pull";
    nrs = "rebuild";
    nrb = "sudo nixos-rebuild boot --flake ~/nix-config/#${hostname}";

    n = "nvim";

    home-vpn-on = "sudo systemctl start wg-quick-wg-home";
    home-vpn-off = "sudo systemctl stop wg-quick-wg-home";
    home-vpn-status = "sudo wg show wg-home";
  };
}
