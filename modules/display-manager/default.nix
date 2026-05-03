{ pkgs, config, ...}:

{
  security.pam.services = {
  	login.fprintAuth = false;
	ly.fprintAuth = false;
  };
 
  services.displayManager.ly = {
  	enable = true;
	x11Support = false;
  };
}
