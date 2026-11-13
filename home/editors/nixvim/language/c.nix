{ pkgs, lib, ... }:

{
  programs.nixvim = {
    plugins = {
      lsp.servers.clangd.enable = true;

      conform-nvim.settings = {
        formatters_by_ft = {
          c = [ "clang-format" ];
          cpp = [ "clang-format" ];
        };
        formatters.clang-format = {
          command = lib.getExe' pkgs.clang-tools "clang-format";
        };
      };
    };

    extraPackages = [ pkgs.clang-tools ];
  };
}
