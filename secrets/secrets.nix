let
  fw16-userkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOptTx0t5KMjGEQ27OnSy7S2QUrDSxXoMR0MIgaSieU";
  fw16-systemkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHdeMjubgGQ2IfzMOIcEM8KzgqzQBmOf8gfK6rMVjG4";
  fw16 = [
    fw16-userkey
    fw16-systemkey
  ];
in
{
  "smb-credentials.age".publicKeys = fw16;
}
