{ pkgs, ... }:

{
  networking.wireless.enable = true;
  networking.wireless.iwd.enable = true;
  
  environment.systemPackages = with pkgs; [
    impala
    bluetui
  ];
}
