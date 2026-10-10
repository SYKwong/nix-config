{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "display-brightness";

  runtimeInputs = with pkgs; [
    coreutils
    hyprland
    jq
  ];

  text = ''
    set -euo pipefail

    STATE_FILE="''${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR is not set}/display_brightness"

    help() {
      echo "Usage: display-brightness [OPTIONS] <action> [step]"
      echo
      echo "Control display brightness with automatic fallback to hyprsunset software dimming."
      echo
      echo "Actions:"
      echo "  up [step]            Increase brightness (default step: 10)"
      echo "  down [step]          Decrease brightness (default step: 10)"
      echo
      echo "Options:"
      echo "  -h, --help           Show this help message"
    }

    has_backlight() {
      for dev in /sys/class/backlight/*; do
        if [[ -e "$dev" ]]; then
          return 0
        fi
      done
      return 1
    }

    is_internal_focused() {
      if ! has_backlight; then
        return 1
      fi

      local monitors_json
      monitors_json="$(hyprctl monitors -j 2>/dev/null || true)"
      if [[ -z "$monitors_json" ]]; then
        return 0
      fi

      local focused_mon
      focused_mon="$(printf '%s\n' "$monitors_json" | jq -r '.[] | select(.focused) | .name' 2>/dev/null || true)"

      if [[ -z "$focused_mon" ]]; then
        return 0
      fi

      if [[ "$focused_mon" =~ ^(eDP|LVDS) ]]; then
        return 0
      fi

      return 1
    }

    get_software_brightness() {
      if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
      else
        echo 100
      fi
    }

    set_software_brightness() {
      local target="''${1:-100}"

      if [[ "$target" -gt 100 ]]; then
        target=100
      elif [[ "$target" -lt 10 ]]; then
        target=10
      fi

      printf '%s\n' "$target" > "$STATE_FILE"
      hyprctl hyprsunset gamma "$target" >/dev/null 2>&1 || true
      noctalia msg brightness-osd "$target" >/dev/null 2>&1 || true
      echo "$target"
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

    ACTION="''${1:-}"
    PARAM="''${2:-}"

    case "$ACTION" in
      up)
        STEP="''${PARAM:-10}"
        if is_internal_focused; then
          noctalia msg brightness-up "$STEP"
        else
          CURRENT=$(get_software_brightness)
          set_software_brightness "$((CURRENT + STEP))"
        fi
        ;;

      down)
        STEP="''${PARAM:-10}"
        if is_internal_focused; then
          noctalia msg brightness-down "$STEP"
        else
          CURRENT=$(get_software_brightness)
          set_software_brightness "$((CURRENT - STEP))"
        fi
        ;;

      *)
        echo "display-brightness: unknown action '$ACTION'" >&2
        echo "Try 'display-brightness --help' for more information." >&2
        exit 2
        ;;
    esac
  '';
}
