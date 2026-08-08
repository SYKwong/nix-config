{ username, ... }:

{
  services.nordvpn.enable = true;

  users.users."${username}" = {
    extraGroups = [
      "nordvpn"
    ];
  };
}
