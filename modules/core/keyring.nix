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
 
  security.pam.services = {
    ly.enableGnomeKeyring = true;
  };
}
