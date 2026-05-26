{ pkgs, ... }:

let
  tuiWrap = pkgs.writeShellScriptBin "tui-wrap" ''
    set -x
    APP_NAME="''${1:-}"

    if [ -z "$APP_NAME" ]; then
      echo "usage: tui-wrap <app>"
      exit 1
    fi

    shift
    
    APP_ID="tui-float.$APP_NAME"
    APP_BIN=$(command -v "$APP_NAME")

    if [ -z "$APP_BIN" ]; then
      echo "Could not find $APP_NAME"
      exit 1
    fi
    
    get_window(){
      hyprctl clients | grep "$APP_ID" || true
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
    exec footclient --app-id="$APP_ID" -e "$APP_BIN" "$@"
  '';
in
{
  environment.systemPackages = [ 
    tuiWrap
    pkgs.foot
  ];
}

