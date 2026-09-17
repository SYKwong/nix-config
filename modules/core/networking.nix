{ hostname, ... }:

{
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall = {
      enable = true;
    };
  };

  # Disable wait-online to prevent blocking boot and rebuilds on dynamic networking
  systemd.services.NetworkManager-wait-online.enable = false;

  # mDNS for local peer-to-peer hostname resolution (<hostname>.local)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
