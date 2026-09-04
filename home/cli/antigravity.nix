{
  programs.antigravity-cli = {
    enable = true;

    permissions = {
      allow = [
        "command(git status.*)"
        "command(git diff.*)"
        "command(git log.*)"
        "command(git show.*)"
        "command(git branch.*)"
        "command(git add.*)"

        "command(nix flake check.*)"
        "command(nix fmt.*)"
        "command(nix eval.*)"
        "command(nix path-info.*)"
        "command(nix build.*)"

        "command(statix check.*)"
        "command(deadnix.*)"

        "command(hyprctl.*)"

        "command(ls.*)"
        "command(cat.*)"
        "command(grep.*)"
        "command(find.*)"
        "command(head.*)"
        "command(tail.*)"

        "write_file(**)"
      ];

      deny = [
        "command(rm -rf /)"
        "command(rm -rf /*)"
        "command(mkfs.*)"
        "command(dd if=.* of=/dev/.*)"
        "command(sudo.*)"
        "write_file(.git/)"
        "write_file(/home/user/.ssh)"
      ];

      ask = [
        "command(rm.*)"
        "command(git rm.*)"
        "command(git commit.*)"
        "command(git push.*)"
        "command(git restore.*)"
        "command(git reset.*)"
        "command(nixos-rebuild.*)"
      ];
    };
  };
}
