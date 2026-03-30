{ pkgs, ... }:

let
  screenshot-src = ./scripts/screenshot.sh; 

  smart-screenshot = pkgs.stdenv.mkDerivation {
    name = "smart-screenshot";
    src = screenshot-src;
    
    # We add bash to buildInputs so patchShebangs knows where it is
    buildInputs = [ pkgs.bash ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    # We don't need a complex build, just copying the file
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/smart-screenshot
      chmod +x $out/bin/smart-screenshot
      
      # 1. This replaces #!/usr/bin/env bash with the Nix store path
      patchShebangs $out/bin/smart-screenshot
      
      # 2. This adds your tools (grim, jq, slurp) to the script's PATH
      wrapProgram $out/bin/smart-screenshot \
        --prefix PATH : ${pkgs.lib.makeBinPath [ 
          pkgs.grim 
          pkgs.slurp
          pkgs.jq 
        ]}
    '';
  };
in
{
  environment.systemPackages = [ smart-screenshot ];
}
