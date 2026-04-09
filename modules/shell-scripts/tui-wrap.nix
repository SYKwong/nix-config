{ pkgs, ... }:

let
  tuiWrap = pkgs.writeShellScriptBin "tui-wrap" ''
    APP_NAME=$1
    shift

    if hyprctl clients | grep -q "tui-float.$APP_NAME"; then
      hyprctl dispatch focuswindow "class:tui-float.$APP_NAME"
      exit 0
    fi

    exec setsid uwsm-app -- xdg-terminal-exec --app-id="tui-float.$APP_NAME" -e "$APP_NAME" "$@"
  '';
in
{
  environment.systemPackages = [ tuiWrap ];
}
