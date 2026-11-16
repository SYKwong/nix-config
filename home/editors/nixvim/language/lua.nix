{ pkgs, ... }:
{
  programs.nixvim = {
    plugins = {
      lsp.servers.lua_ls.enable = true;
      conform-nvim.settings = {
        formatters_by_ft.lua = [ "stylua" ];
      };
    };

    extraPackages = [ pkgs.stylua ];
  };
}
