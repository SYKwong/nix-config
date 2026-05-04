{
  security.pam.services = {
  	login.fprintAuth = false;
	ly.fprintAuth = false;
  };
 
  services.displayManager.ly = {
  	enable = true;
	x11Support = false;
	settings = {
		bigclock = true;
		bigclock_12hr = true;

		hide_key_hints = true;
		hide_version_string = true;
	};
  };
}
