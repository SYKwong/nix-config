{ pkgs, lib, config, ... }:
{
  services.gnome.gnome-keyring.enable = true;
  programs.ssh.startAgent = false;
  programs.ssh.extraConfig = ''
    AddKeysToAgent yes
  '';

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
        ExecStart = "${pkgs.openssh}/bin/ssh-add -l";
        RemainAfterExit = true;
      };
    };

  };
 
  environment.sessionVariables = {
    GSM_SKIP_SSH_AGENT_WORKAROUND = "1";
    SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/keyring/ssh";
  };


}
