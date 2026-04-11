{
  imports = [ 
    ./../../modules/home/cli
    ./../../modules/home/browsers  

    ./alias.nix
    ./dotfile.nix
  ];
  
  programs.bash = {
    enable = true;
  };
}
