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
 

  #programs.ssh = {
  #  extraConfig = ''
  #    # Global Config
  #    Host *
  #      IgnoreUnknown UseKeychain
  #      AddKeysToAgent yes
  #      UseKeychain yes
  #      IdentitiesOnly yes
  #  '';
  #};

  security.pam.services = {
    sddm.enableGnomeKeyring = true;
  #  greetd.enableGnomeKeyring = true;
  #  greetd-password.enableGnomeKeyring = true;
  #  hyprlock.enableGnomeKeyring = true;
  #  login.enableGnomeKeyring = true;
  };

  #environment.variables = {
  #  SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
  #  SSH_ASKPASS = lib.mkForce "${pkgs.gcr_4}/libexec/gcr4-ssh-askpass";
  #  GNOME_KEYRING_CONTROL = "$XDG_RUNTIME_DIR/keyring";
  #  SIGNAL_PASSWORD_STORE = "gnome-libsecret";
  #}; 
}
