{
  networking.wg-quick.interfaces.wg-home = {
    autostart = false;

    address = [ "10.6.0.2/32" ];
    dns = [ "10.6.0.1" ];
    peers = [
      {
        publicKey = "HMNJm1ZJxA6nuAxzz8+ySbd0S4Mi1Su6ebrVf7wvRyw=";
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = "76.237.100.199:51820";
        persistentKeepalive = 25;
      }
    ];
  };
}
