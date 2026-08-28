{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "kb-light-manager";

  runtimeInputs = with pkgs; [
    qmk
    qmk_hid
    gnugrep
    coreutils
  ];

  text = ''
    set -euo pipefail

    help() {
      echo "Usage: kb-light-manager [OPTIONS] <action> <vid> <pid>"
      echo
      echo "Control the backlight of a QMK keyboard."
      echo
      echo "Actions:"
      echo "  off                  Save the current brightness and turn it off"
      echo "  on                   Restore the saved brightness"
      echo
      echo "Options:"
      echo "  -h, --help           Show this help message"
      echo
      echo "Arguments:"
      echo "  vid                  USB vendor ID (4 hexadecimal characters)"
      echo "  pid                  USB product ID (4 hexadecimal characters)"
      echo
      echo "If no saved brightness exists, 'on' restores the brightness to 100."
    }

    fail() {
      printf 'kb-light-manager: %s\n' "$*" >&2
      printf '%s\n' "Try 'kb-light-manager --help' for more information." >&2
      exit 2
    }

    if [[ $# -eq 0 ]]; then
      help
      exit 0
    fi

    case "$1" in
      -h|--help)
        help
        exit 0
        ;;
    esac

    [[ $# -eq 3 ]] || fail "expected 3 arguments, got $#"

    ACTION="''${1:-}"
    VID="''${2:-}"
    PID="''${3:-}"

    if [[ -z "$ACTION" || -z "$VID" || -z "$PID" ]]; then
      echo "Usage: kb-light-manager <off|on> <vid> <pid>" >&2
      exit 2
    fi

    STATE_FILE="/tmp/kb_state_''${VID}_''${PID}"

    case "$ACTION" in
      off)
        CURRENT=$(
          qmk_hid \
            --vid "$VID" \
            --pid "$PID" \
            via --backlight |
          grep -o '[0-9]\+' |
          head -n 1
        )

        printf '%s\n' "$CURRENT" > "$STATE_FILE"

        qmk_hid \
          --vid "$VID" \
          --pid "$PID" \
          via --backlight 0
        ;;

      on)
        if [[ -f "$STATE_FILE" ]]; then
          VAL=$(<"$STATE_FILE")
        else
          VAL=100
        fi

        qmk_hid \
          --vid "$VID" \
          --pid "$PID" \
          via --backlight "$VAL"
        ;;

      *)
        echo "Usage: kb-light-manager <off|on> <vid> <pid>" >&2
        exit 2
        ;;
    esac
  '';
}
