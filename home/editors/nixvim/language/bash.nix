{ pkgs, ... }:

{
  programs.nixvim = {
    plugins = {
      lsp.servers = {
        bashls.enable = true;
      };

      conform-nvim.settings = {
        formatters_by_ft.sh = [ "shfmt" ];
        formatters_by_ft.bash = [ "shfmt" ];
        formatters = {
          shfmt = {
            prepend_args = [
              "-i"
              "2"
              "-ci"
              "-s"
            ];
          };
        };
      };

      lint.lintersByFt = {
        sh = [ "shellcheck" ];
        bash = [ "shellcheck" ];
      };
    };

    extraPackages = with pkgs; [
      bash-language-server
      shellcheck
      shfmt
    ];

    autoCmd = [
      {
        event = [ "FileType" ];
        pattern = [
          "sh"
          "bash"
        ];
        command = "setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab";
      }
    ];
  };
}
