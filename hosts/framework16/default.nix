{ ... }: 

{
  imports = [
    ./framework16-luks.nix
    ./hardware-configuration.nix
    ./luks.nix
  ];
}
