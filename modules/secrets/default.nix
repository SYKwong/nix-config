{
  age.secrets = {
    smb-credentials.file = ../../secrets/smb-credentials.age;

    cloudflare-workers-ai-apikey = {
      file = ../../secrets/cloudflare-workers-ai-apikey.age;
      owner = "1000";
      group = "100";
      mode = "0400";
    };

    wireguard-fw16.file = ../../secrets/wireguard-fw16.age;
  };
}
