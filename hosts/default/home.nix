{
  imports = [ 
    ./../../modules/home/cli

    ./alias.nix
    ./dotfile.nix
  ];
  
  programs.bash = {
    enable = true;
  };
}
