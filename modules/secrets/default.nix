{ username, ... }:

{
  age.secrets = {
    smb-credentials.file = ../../secrets/smb-credentials.age;

    atuin-credentials = {
      file = ../../secrets/atuin-credentials.age;
      owner = username;
      group = "users";
      mode = "0400";
    };
  };
}
