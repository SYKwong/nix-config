let
  keys = import ./keys.nix;
  fw16 = [
    keys.users.fw16
    keys.systems.fw16
  ];
in
{
  "smb-credentials.age".publicKeys = fw16;
  "cloudflare-workers-ai-apikey.age".publicKeys = fw16;
  "wireguard-fw16.age".publicKeys = fw16;
}
