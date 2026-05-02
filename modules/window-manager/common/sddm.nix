{
  services.displayManager.sddm = {
    enable = true;
  
    wayland.enable = true;
  };

  security.pam.services.login.fprintAuth = false;
}
