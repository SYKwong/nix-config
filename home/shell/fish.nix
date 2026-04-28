{
  programs = {
    fish.enable = true;

    starship = {
      enable = true;
      enableFishIntegration = true;
      
      enableTransience = true;
      presets = [ "nerd-font-symbols" ];
      
      #settings = {
        #add_newline = true;
        #line_break.disabled = true;
	#"palette" = 'catppuccin_mocha';
      #};
    };
  };
}
