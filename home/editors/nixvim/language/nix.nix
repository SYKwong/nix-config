{ pkgs, ... }:

{
  programs.nixvim = {
    plugins = {
      lsp.servers = {
        nixd.enable = true;
        statix.enable = true;
      };
      conform-nvim.settings = {
        formatters_by_ft.nix = [ "nixfmt" ];
      };
      lint.lintersByFt.nix = [ "statix" ];
    };

    extraPackages = with pkgs; [
      statix
      nixfmt
    ];

    autoCmd = [
      {
        event = [ "FileType" ];
        pattern = [ "nix" ];
        command = "setlocal tabstop=2 shiftwidth=2 softtabstop=2";
      }
    ];
  };
}
