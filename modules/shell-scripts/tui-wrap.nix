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

    for i in {1..20}; do # Try for 2 seconds (20 * 0.1s)
      NEW_INSTANCE=$(get_window)
      if [ -n "$NEW_INSTANCE" ] && [ "$NEW_INSTANCE" != "null" ]; then
        focus_and_warp 
        exit 0
      fi
      sleep 0.1
    done

  '';
in
{
  environment.systemPackages = [ tuiWrap ];
}
