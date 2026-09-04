{ config, ... }:

{
  custom.vpn.wireguard.enable = true;

  age.secrets.wireguard-fw16.file = ../../secrets/wireguard-fw16.age;

  networking.wg-quick.interfaces.wg-home = {
    privateKeyFile = config.age.secrets.wireguard-fw16.path;
  };
}
