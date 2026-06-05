{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "rofi-profile-menu";

  runtimeInputs = with pkgs; [
    rofi
    power-profiles-daemon
    libnotify
    gnused
  ];

  text = ''
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
      -selected-row "$active_idx" \
      -theme-str '
        inputbar { enabled: false; }
        window { width: 300px; border-radius: 12px; } 
        
        listview { 
            lines: 3; 
            fixed-height: true; 
            spacing: 4px;
            margin: 8px;
            padding: 0px;
        }
        
        prompt { enabled: false; }
        
        element { 
            padding: 8px 12px;
            border-radius: 8px;
        }
        
        element-text { 
            vertical-align: 0.5; 
            horizontal-align: 0.0; 
            background-color: @transparent;
        }
        
        element-icon { enabled: false; }
      ')

    chosen="''${chosen//<i>/}"
    chosen="''${chosen//<\/i>/}"

    if [[ -n "$chosen" && "$chosen" != "$current" ]]; then
      powerprofilesctl set "$chosen"
      notify-send "Power Profile" "Switched to $chosen" -i "battery-good"
    fi
  '';
}
