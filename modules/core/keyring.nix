{ pkgs, lib, ... }:
{
  services.gnome ={
    gnome-keyring.enable = true;
    gcr-ssh-agent.enable = true;
  };

  environment.systemPackages = with pkgs; [
    libsecret
    seahorse
    gcr_4
  ];

  services.dbus.packages = [ pkgs.gcr_4 ];
  
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

  systemd.user.services.proactive-keyring-unlock = {
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

  environment.variables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
    SSH_ASKPASS = lib.mkForce "${pkgs.gcr_4}/libexec/gcr4-ssh-askpass";
    GNOME_KEYRING_CONTROL = "$XDG_RUNTIME_DIR/keyring";
    SIGNAL_PASSWORD_STORE = "gnome-libsecret";
  }; 
}
