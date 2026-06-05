{ pkgs, lib, ... }:
{
  programs.nixvim = {
    plugins = {
      lsp.servers.lua_ls.enable = true;
      conform-nvim.settings = {
        formatters_by_ft.lua = [ "stylua" ];
        formatters.stylua = {
          command = lib.getExe pkgs.stylua;
        };
      };
    };

    extraPackages = with pkgs; [ stylua ];
  };
}
