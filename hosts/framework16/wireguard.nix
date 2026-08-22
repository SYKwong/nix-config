{ config, ... }:

{
  networking.wg-quick.interfaces.wg-home = {
    privateKeyFile = config.age.secrets.wireguard-fw16.path;
  };
}
