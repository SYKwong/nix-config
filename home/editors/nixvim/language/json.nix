{ pkgs, ... }:

{
  programs.nixvim = {
    plugins = {
      lsp.servers.jsonls.enable = true;

      conform-nvim.settings = {
        formatters_by_ft = {
          json = [ "deno_fmt" ];
          jsonc = [ "deno_fmt" ];
        };
      };

      lint.lintersByFt = {
        json = [ "deno" ];
        jsonc = [ "deno" ];
      };
    };

    extraPackages = with pkgs; [
      deno
    ];

    autoCmd = [
      {
        event = [ "FileType" ];
        pattern = [
          "json"
          "jsonc"
        ];
        command = "setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab";
      }
    ];
  };
}
