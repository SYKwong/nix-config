{ pkgs, ... }:

let
  wallpaperSync = import ../shell-scripts/wallpaper-sync.nix { inherit pkgs; };
in
{
  systemd.user.services.wallpaper-sync = {
    description = "Synchronize wallpaper git repository";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${wallpaperSync}/bin/wallpaper-sync";
      Environment = [
        "SSH_AUTH_SOCK=%t/gcr/ssh"
      ];
    };
  };

  systemd.user.timers.wallpaper-sync = {
    description = "Daily synchronization of wallpaper git repository";
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "15m";
    };
    wantedBy = [ "timers.target" ];
  };
}
