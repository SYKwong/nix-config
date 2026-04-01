{ username, ... }:

{
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=8G" "mode=755" ];
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/etc/NetworkManager/system-connections"
    ];
    files = [ "/etc/machine-id" ];

    # SELECTIVE HOME: List exactly what you want to keep
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
