{ username, ... }:

{
  time.timeZone = "America/Los_Angeles";

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
    optimise.automatic = true;
  };

  system.stateVersion = "26.05";
  documentation.nixos.enable = false;

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3";
    };
    flake = "/home/${username}/nix-config";
  };

  nixpkgs.config.allowUnfree = true;
}
