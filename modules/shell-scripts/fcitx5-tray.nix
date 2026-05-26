{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "fcitx5-tray";

  runtimeInputs = with pkgs; [
    fcitx5
  ];
  text = ''
    get_im() {
      current_im=$(fcitx5-remote -n 2>/dev/null)

      case "$current_im" in
        "keyboard-us")    echo "EN" ;;
        "quick-classic")  echo "速" ;;
        "mozc")           echo "JP" ;;
        *)                echo "$current_im" ;; # Fallback to the raw name
      esac
    }

    get_im

    dbus-monitor --session "interface='org.kde.StatusNotifierItem',member='NewIcon'"  2>/dev/null | \
    while read -r _; do
      get_im
    done
  '';
}
