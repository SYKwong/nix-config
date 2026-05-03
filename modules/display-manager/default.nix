{ pkgs, config, ...}:

{
  #programs.silentSDDM = {
  #  enable = true;
  #  theme = "silvia";
  #  settings = { 
  #  	"LoginScreen.MenuArea.Layout" 	= {
  #      	"display" = "false";
  #      };
  #  	"LoginScreen.MenuArea.Keyboard" = {
  #      	"display" = "false";
  #      };

  #  };
  #};
  security.pam.services = {
  	login.fprintAuth = false;
	ly.fprintAuth = false;
  };
 
  services.displayManager.ly = {
  	enable = true;
	x11Support = false;
  };
}
