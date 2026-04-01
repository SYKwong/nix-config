{ username, ...}:

{
  imports = [
    ../default/home.nix
  ];

  home-manger.users.${username}.home.stateVersion = "26.05";
}
