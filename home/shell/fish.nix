{
  programs = {
    fish.enable = true;

    starship = {
      enable = true;
      enableFishIntegration = true;
      
      enableTransience = true;
      settings = {
        add_newline = true;
        line_break.disabled = true;
      };
    };
  };
}
