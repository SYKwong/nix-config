{ pkgs, lib, config, ... }:
{
  services.gnome ={
    gnome-keyring.enable = true;
    gcr-ssh-agent.enable = true;
  };

  environment.systemPackages = with pkgs; [
    libsecret
  ]

  programs.ssh = {
    startAgent = false;
    ssh.extraConfig = ''
      AddKeysToAgent yes
    '';
  };

  services.dbus.packages = [ pkgs.gcr ];

  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    greetd-password.enableGnomeKeyring = true;
    hyprlock.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };

  systemd.user.services = {
    hyprpolkitagent = {
      description = "Hyprpolkit authentication agent";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    proactive-keyring-unlock = {
      description = "Proactively trigger GNOME Keyring unlock prompt on login";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        Environment = "SSH_AUTH_SOCK=/run/user/%U/keyring/ssh";
        ExecStart = "${pkgs.libsecret}/bin/secret-tool lookup name unlock-trigger";
        RemainAfterExit = true;
      };
    };

  };
 
  environment.sessionVariables = {
    GSM_SKIP_SSH_AGENT_WORKAROUND = "1";
    SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
  };

  security.pam.services.hyprlock = {
  gnomeKeyring = true;
  text = ''
    auth      include   login
    # We ensure fingerprint is 'optional' so it doesn't short-circuit the keyring
    auth      optional  pam_fprintd.so
    auth      optional  pam_gnome_keyring.so
    session   optional  pam_gnome_keyring.so auto_start
  '';
};

}
