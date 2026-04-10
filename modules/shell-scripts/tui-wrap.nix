{ pkgs, ... }:

let
  tuiWrap = pkgs.writeShellScriptBin "tui-wrap" ''
    APP_NAME=$1
    shift
    
    APP_ID="tui-float.$APP_NAME"
    
    get_window(){
      hyprctl clients | grep "$APP_ID"
    }

    focus_and_warp() {
      hyprctl dispatch focuswindow "class:$APP_ID"
      hyprctl dispatch alterzorder top
    }

    ALREADY_EXIST=$(get_window)

    if [ -n "$ALREADY_EXIST" ] && [ "$ALREADY_EXIST" != "null" ]; then
      focus_and_warp
      exit 0
    fi

    exec setsid uwsm-app -- xdg-terminal-exec --app-id="$APP_ID" -e "$APP_NAME" "$@"
    read -r W H < <(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.width) \(.height)"')
    hyprctl dispatch movecursor $((W/2)) $((H/2))
  '';
in
{
  environment.systemPackages = [ tuiWrap ];
}
