{
  programs.silentSDDM = {
    enable = true;
    theme = "silvia";
    # settings = { ... }; see example in module
  };
  security.pam.services.login.fprintAuth = false;
}
