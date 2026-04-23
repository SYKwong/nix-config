{ pkgs, ... }:

let
  fcitx5-tray = pkgs.writeShellScriptBin "fcitx5-tray" ''
    get_current_in() {
      current_im=$(fcitx5-remote -n 2>/dev/null)

      case "$current_im" in
        "keyboard-us")    echo "EN" ;;
        "quick-classic")  echo "速" ;;
        "mozc")           echo "JP" ;;
        *)                echo "$im" ;; # Fallback to the raw name
      esac
    }

    get_im

    dbus-monitor --profile "interface='org.fcitx.Fcitx5.Controller1',member='Notify'" 2>/dev/null |
    while read -r line; do
      get_im
    done

  '';
in
{
  environment.systemPackages = [ fcitx5-tray ];
}
