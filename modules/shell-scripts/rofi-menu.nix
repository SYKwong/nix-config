{ pkgs, ... }:

let
  rofi-menu = pkgs.writeShellScriptBin "rofi-menu" ''
    #[NF-icon][two space][Name]
    options="\
    󰸉  Wallpaper\n\
    󰐥  System\n\
    󱐋  Power Profile\n\
    󰖩  Wi-Fi\n\
    󰂯  Bluetooth\n\
    󰕾  Audio"

    chosen=$(echo -e "$options" | rofi -dmenu \
      -i \
      -theme-str '
        element-icon { enabled: false; }
        prompt { enabled: false; }
        window { width: 250; }
        listview { dynamic: true; fixed-height: false; lines: 10; }
    ')

    cleanup_input=$(echo "$chosen" | tr -cd '[:print:]' | xargs)
    
    case "$cleanup_input" in
      "System")
        rofi-power-menu ;;
      "Power Profile")
        rofi-power-profile ;;
      "Wi-Fi")
        tui-wrap impala ;;
      "Bluetooth")
        tui-wrap bluetui ;;
      "Audio")
        tui-wrap wiremix ;;
      "Wallpaper")
        rofi-wallpaper-picker ;;
      *)
        exit 1 ;;
    esac
  '';


  rofi-power-profile = pkgs.writeShellScriptBin "rofi-power-profile" ''
    current=$(powerprofilesctl get)
    case "$current" in
      "performance") active_idx=0 ;;
      "balanced")    active_idx=1 ;;
      "power-saver") active_idx=2 ;;
      *)             active_idx=-1 ;;
    esac

    options="performance\nbalanced\npower-saver"
    options=$(echo -e "$options" | sed "s/^$current$/<i>$current<\/i>/")

    chosen=$(echo -e "$options" | rofi -dmenu \
      -i \
      -markup-rows \
      -theme-str '
        window { width: 300; } 
        listview { lines: 3; }
        prompt { enabled: false; }
        element { padding: 10px 10px; }
        element-text { horizontal-align: 0; }
        element-icon { enabled: false; }
      ')
    
    chosen=$(echo "$chosen" | sed 's/<[^>]*>//g')
  
    if [[ -n "$chosen" && "$chosen" != "$current" ]]; then
      powerprofilesctl set "$chosen"
      notify-send "Power Profile" "Switched to $chosen" -i "battery-good"
    fi

  '';

  rofi-power-menu = pkgs.writeShellScriptBin "rofi-power-menu" ''
    options="󰐥 Shutdown\n󰒲 Suspend\n󰤁 Hibernate\n󰜉 Reboot\n󰍃 Logout\n Lock"

    chosen=$(echo -e "$options" | rofi -dmenu \
      -i \
      -theme-str '
        window { width: 300; } 
        listview { lines: 6; } 
        prompt { enabled: false; }
        element { padding: 10px 10px; }
        element-text { horizontal-align: 0; }
        element-icon { enabled: false; }
      ')

    case "$chosen" in
      "󰐥 Shutdown")
        systemctl poweroff ;;
      "󰒲 Suspend")
        systemctl suspend-then-hibernate ;;
      "󰤁 Hibernate")
        systemctl hibernate ;;
      "󰜉 Reboot")
        systemctl reboot ;;
      "󰍃 Logout")
        loginctl terminate-user $USER ;;
      " Lock")
        pidof hyprlock || hyprlock ;; 
      *)
        exit 1 ;;
    esac
  '';
in
{
  environment.systemPackages = [ 
    rofi-menu
    rofi-power-profile
    rofi-power-menu
  ];
}
