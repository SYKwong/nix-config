{
  stylix.targets.zed.enable = true;

  programs.zed-editor = {
    enable = true;

    extensions = [
      "nix"
      "toml"
      "make"
      "lua"
      "git-firefly"
    ];

  };
}
