{ pkgs, lib, config, ... }:
{
  services.gnome ={
    gnome-keyring.enable = true;
    gcr-ssh-agent.enable = true;
  };

  environment.systemPackages = with pkgs; [
    libsecret
    seahorse
  ];

  programs.ssh = {
    extraConfig = ''
      # Global Config
      Host *
        IgnoreUnknown UseKeychain
        AddKeysToAgent yes
        UseKeychain yes
        IdentitiesOnly yes
    '';
  };

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

}
