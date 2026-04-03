{ username, ...}:

{
  imports = [
    ../default/home.nix
  ];

  home-manager.users.${username}.home.stateVersion = "26.05";
}
