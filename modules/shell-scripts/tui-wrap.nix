{ pkgs, ... }:

let
  tuiWrap = pkgs.writeShellScriptBin "tui-wrap" ''
    # Default terminal if $TERMINAL isn't set
    TERM_BIN="''${TERMINAL:-kitty}"
    
    # The first argument is the app (e.g., btop), the rest are args for that app
    APP_NAME=$1
    shift

    # Launch terminal with a specific class for WM rules
    # Note: different terminals use different flags for class/title
    # Ghostty/Foot/Kitty: --class
    # Alacritty: --class or --title
    exec "$TERM_BIN" --class "tui-float" -e "$APP_NAME" "$@"
  '';
in
{
  environment.systemPackages = [ tuiWrap ];
}
