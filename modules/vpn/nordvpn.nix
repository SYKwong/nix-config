{ username, ... }:

{
  services.nordvpn.enable = true;
  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = [
      "nordlynx"
      "tun20"
      "nordvpn"
    ];
  };

  users.users."${username}" = {
    extraGroups = [
      "nordvpn"
    ];
  };
}
