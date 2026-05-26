{ pkgs, ... }:

let
  tuiWrap = pkgs.writeShellScriptBin "tui-wrap" ''
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
    
    get_window() {
      hyprctl clients | grep "$APP_ID" || true
    }
    
    move_cursor_to_center() {
      read -r W H < <(hyprctl monitors | awk '/^[ \t]*[0-9]+x[0-9]+/ {last=$1} /focused: yes/ {print last}' | sed 's/x/ /; s/@.*//')
      X=$((W/2))
      Y=$((H/2))
      hyprctl dispatch "hl.dsp.cursor.move({ x = ''${X}, y = ''${Y} })"
    }

    focus_and_warp() {
      WORKSPACE=$(hyprctl activeworkspace | awk '/workspace ID/ {print $3}')
      hyprctl dispatch "hl.dsp.window.move({ window = \"class:$APP_ID\", workspace = \"$WORKSPACE\" })"
      hyprctl dispatch 'hl.dsp.focus({ window = "'"class:$APP_ID"'" })'
      hyprctl dispatch 'hl.dsp.window.alter_zorder({ mode = "top" })'
    }

    ALREADY_EXIST=$(get_window)
    move_cursor_to_center

    if [ -n "$ALREADY_EXIST" ] && [ "$ALREADY_EXIST" != "null" ]; then
      focus_and_warp
      exit 0
    fi

    exec footclient --app-id="$APP_ID" -e "$APP_BIN" "$@"
  '';
in
{
  environment.systemPackages = [ 
    tuiWrap
    pkgs.foot
  ];
}

