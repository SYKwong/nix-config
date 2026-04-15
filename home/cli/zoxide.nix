{
  programs.zoxide ={
    enable = true;
    options = [ "--cmd cd" ];
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };
}

