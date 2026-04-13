{ username, session-command, ... }:

{
  programs.regreet.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${session-command} &>/dev/null";
        user = "${username}";
      };
      default_session = {
        command = "${session-command} &>/dev/null";
        user = "${username}";
      };
    };
  };
}

