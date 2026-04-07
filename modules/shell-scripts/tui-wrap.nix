{ pkgs, ... }:

let
  tuiWrap = pkgs.writeShellScriptBin "tui-wrap" ''
    APP_NAME=$1
    shift

    exec setsid uwsm-app -- xdg-terminal-exec --app-id="tui-float.$APP_NAME" -e "$APP_NAME" "$@"
  '';
in
{
  environment.systemPackages = [ tuiWrap ];
}
