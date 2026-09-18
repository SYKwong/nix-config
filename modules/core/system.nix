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
      extra-substituters = [
        "http://mini-pc-k8.local:5000"
      ];
      extra-trusted-public-keys = [
        "mini-pc-k8-1:4Tac3TqWj59aZkbxxJ+ux931MXNVnvWrU1xGAll40KE="
      ];
      connect-timeout = 2;
      download-attempts = 2;
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
