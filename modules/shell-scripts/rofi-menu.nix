{ pkgs, ... }:

let
  rofi-menu = pkgs.writeShellScriptBin "rofi-menu" ''
    options="󰐥 System\n󱐋 Power Profile"

    chosen=$(echo -e "$options" | rofi -dmenu -i )
    case "$chosen" in
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
      -p "Power Profile" \
      -theme-str '
        window { width: 300; } 
        listview { lines: 3; } 
        prompt { enabled: false; }
        element { padding: 10px 10px; }
        element-text { horizontal-align: 0;}
        element-icon { enabled: false; }
      ')
    
    chosen=$(echo "$chosen" | sed 's/<[^>]*>//g')
  
    if [[ -n "$chosen" && "$chosen" != "$current" ]]; then
      powerprofilesctl set "$chosen"
      notify-send "Power Profile" "Switched to $chosen" -i "battery-good"
    fi

  '';

  rofi-power-menu = pkgs.writeShellScriptBin "rofi-power-menu" ''
    options="Shutdown\nSuspend\nHibernate\nReboot\nLog Out\nLock"

    chosen=$(echo -e "$options" | rofi -dmenu \
      -i \
      -p "Power Profile" \
      -theme-str '
        window { width: 300; } 
        listview { lines: 6; } 
        prompt { enabled: false; }
        element { padding: 5px 10px; }
        element-text { horizontal-align: 0;}
        element-icon { enabled: false; }
      ')

    case "$chosen" in
      "Shutdown")
        systemctl poweroff ;;
      "Suspend")
        systemctl suspend-then-hibernate ;;
      "Hibernate")
        systemctl hibernate ;;
      "Reboot")
        systemctl reboot ;;
      "Log Out")
        loginctl terminate-user $USER ;;
      "Lock")
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
