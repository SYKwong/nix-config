{ hostname, ... }:

{
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall = {
      enable = true;
    };
  };

  # mDNS for local peer-to-peer hostname resolution (<hostname>.local)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
