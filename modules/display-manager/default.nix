{
  programs.silentSDDM = {
    enable = true;
    theme = "silvia";
    settings = { 
    	"LoginScreen.MenuArea.Layout" 	= {
		"display" = "false";
	};
    	"LoginScreen.MenuArea.Keyboard" = {
		"display" = "false";
	};

    };
  };
  security.pam.services.login.fprintAuth = false;
}
