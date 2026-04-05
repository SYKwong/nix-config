{ pkgs, lib, ... }: 

{
  environment.systemPackages = [ pkgs.sbctl ];
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    autoEnrollKeys = {
      enable = true;
      autoReboot = true;
    };
  };
}
