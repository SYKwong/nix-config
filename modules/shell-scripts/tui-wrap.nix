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

    read -r W H < <(hyprctl monitors | awk '/^[ \t]*[0-9]+x[0-9]+/ {last=$1} /focused: yes/ {print last}' | sed 's/x/ /; s/@.*//')
    hyprctl dispatch movecursor $((W/2)) $((H/2))
    exec footclient --app-id="$APP_ID" -e "$APP_NAME" "$@"
    ''
  ;
in
{
  environment.systemPackages = [ tuiWrap ];
}
