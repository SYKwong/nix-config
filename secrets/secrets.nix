let
  keys = import ./keys.nix;
  allKeys = (builtins.attrValues keys.users) ++ (builtins.attrValues keys.systems);
in
{
  "smb-credentials.age".publicKeys = allKeys;
  "cloudflare-workers-ai-apikey.age".publicKeys = allKeys;
  "wireguard-fw16.age".publicKeys = [
    keys.users.framework16
    keys.systems.framework16
  ];
  "harmonia-signing-key.age".publicKeys = [
    keys.users.framework16
    keys.users."mini-pc-k8"
    keys.systems."mini-pc-k8"
  ];
  "atuin-credentials.age".publicKeys = allKeys;
}
