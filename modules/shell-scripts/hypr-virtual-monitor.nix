{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "hypr-virtual-monitor";

  runtimeInputs = with pkgs; [
    coreutils
    gnugrep
    hyprland
    iproute2
    jq
    libnotify
    systemd
  ];

  text = ''
    ACTION="''${1:-toggle}"
    OUTPUT_NAME="''${2:-HEADLESS-1}"
    WIDTH="''${SUNSHINE_CLIENT_WIDTH:-2960}"
    HEIGHT="''${SUNSHINE_CLIENT_HEIGHT:-1848}"
    FPS="''${SUNSHINE_CLIENT_FPS:-120}"
    SCALE="''${3:-''${TABLET_SCALE:-1.6}}"

    is_running() {
      hyprctl monitors -j | jq -e --arg name "$OUTPUT_NAME" '.[] | select(.name == $name)' >/dev/null 2>&1
    }

    start_monitor() {
      if ! is_running; then
        hyprctl output create headless "$OUTPUT_NAME"
      fi
      hyprctl eval "hl.monitor({ output = \"$OUTPUT_NAME\", mode = \"''${WIDTH}x''${HEIGHT}@''${FPS}Hz\", position = \"auto-right\", scale = \"$SCALE\", reserved_area = { top = 20, bottom = 0, left = 0, right = 0 } })"
      systemctl --user start sunshine-watchdog.service >/dev/null 2>&1 || true
    }

    stop_monitor() {
      systemctl --user stop sunshine-watchdog.service >/dev/null 2>&1 || true
      if is_running; then
        hyprctl output remove "$OUTPUT_NAME"
      fi
    }

    watchdog() {
      local max_idle="''${3:-900}"
      local check_interval=15
      local idle_time=0

      while true; do
        sleep "$check_interval"
        if ! is_running; then
          idle_time=0
          continue
        fi

        # HEADLESS monitor is active. Check for active streaming TCP sockets (ports 47989, 48010)
        if ss -Htn state established 'sport = :47989 or sport = :48010' | grep -q .; then
          idle_time=0
          continue
        fi

        idle_time=$((idle_time + check_interval))
        if [ "$idle_time" -ge "$max_idle" ]; then
          if is_running; then
            hyprctl output remove "$OUTPUT_NAME"
          fi
          systemctl --user restart sunshine >/dev/null 2>&1 || true
          notify-send -a 'Sunshine' 'Tablet Display' "Session idle for $((max_idle / 60)) minutes: virtual monitor removed." >/dev/null 2>&1 || true
          exit 0
        fi
      done
    }

    case "$ACTION" in
      start)
        start_monitor
        ;;
      stop)
        stop_monitor
        ;;
      toggle)
        if is_running; then
          stop_monitor
        else
          start_monitor
        fi
        ;;
      watchdog)
        watchdog
        ;;
      *)
        echo "Usage: hypr-virtual-monitor {start|stop|toggle|watchdog} [output_name] [scale_or_timeout]" >&2
        exit 1
        ;;
    esac
  '';
}
