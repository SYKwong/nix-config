{ username, ... }:

{
  age.secrets = {
    smb-credentials.file = ../../secrets/smb-credentials.age;

    cloudflare-workers-ai-apikey = {
      file = ../../secrets/cloudflare-workers-ai-apikey.age;
      owner = username;
      group = "users";
      mode = "0400";
    };
  };
}
