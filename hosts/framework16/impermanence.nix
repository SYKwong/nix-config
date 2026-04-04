{ username, ... }:

{
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/mnt/var/lib/sbctl"
      "/etc/NetworkManager/system-connections"
    ];
    files = [ "/etc/machine-id" ];

    users.${username} = {
      directories = [
        "Documents"
        "Downloads"
        "Pictures"
        "Projects"
        ".ssh"
      ];
      files = [ ".bash_history" ];
    };
  };
  
  programs.fuse.userAllowOther = true;
}
