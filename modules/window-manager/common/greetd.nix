{ lib, username, session-command, ... }:

{ 
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${session-command} &>/dev/null";
        user = "${username}";
      };
      default_session = {
        command = "${session-command} &>/dev/null";
        user = "${username}";
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = lib.mkForce "simple";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Redirect errors so they don't print to screen
    TTYReset = "yes";
    TTYVHangup = "yes";
    TTYVTDisallocate = "yes";
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
