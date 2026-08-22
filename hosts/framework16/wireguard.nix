{ config, ... }:

{
  custom.vpn.wireguard.enable = true;
  networking.wg-quick.interfaces.wg-home = {
    privateKeyFile = config.age.secrets.wireguard-fw16.path;
  };
}
