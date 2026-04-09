{ pkgs, ... }:

let
  tuiWrap = pkgs.writeShellScriptBin "tui-wrap" ''
    APP_NAME=$1
    shift
    
    APP_ID="tui-float.$APP_NAME"
    
    get_window(){
      hyprctl clients | grep -q "tui-float.$APP_NAME"
    }

    focus_and_warp() {
      local id=$1
      hyprctl dispatch focuswindow "class:$id"
      hyprctl dispatch alterzorder top
    }

    EXISTING_ID=$(get_window)

    if [ -n "$EXISTING_ID" ] && [ "$EXISTING_ID" != "null" ]; then
      focus_and_warp "$EXISTING_ID"
      exit 0
    fi

    exec setsid uwsm-app -- xdg-terminal-exec --app-id="$APP_ID" -e "$APP_NAME" "$@"

    for i in {1..20}; do # Try for 2 seconds (20 * 0.1s)
      NEW_ID=$(get_window)
      if [ -n "$NEW_ID" ] && [ "$NEW_ID" != "null" ]; then
        focus_and_warp "$NEW_ID"
        exit 0
      fi
      sleep 0.1
    done

  '';
in
{
  environment.systemPackages = [ tuiWrap ];
}
