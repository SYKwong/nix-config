{ username, ... }:

{
  documentation.nixos.enable = false;
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
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

  programs = {
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = "/home/${username}/nix-config";
    };

    # Needed for the rebuild script as it uses the root user
    git = {
      enable = true;
      config.safe.directory = [
        "/home/${username}/nix-config"
      ];
    };
  };
}
