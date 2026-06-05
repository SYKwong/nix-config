{ pkgs, lib, ... }:

{
  programs.nixvim = {
    plugins = {
      lsp.servers = {
        nixd.enable = true;
        statix.enable = true;
      };
      conform-nvim.settings = {
        formatters_by_ft.nix = [ "nixfmt" ];
        formatters.nixfmt.command = lib.getExe pkgs.nixfmt;
      };
      lint.lintersByFt.nix = [ "statix" ];
    };

    extraPackages = with pkgs; [
      statix
      nixfmt-rfc-style
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
