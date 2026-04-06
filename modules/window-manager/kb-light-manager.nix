{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "kb-light-manager";
      runtimeInputs = [
        pkgs.qmk
        pkgs.qmk_hid 
        pkgs.gnugrep 
        pkgs.coreutils
      ];
      text = builtins.readFile ./scripts/kb-light-manager.sh;
    })
  ];
}
