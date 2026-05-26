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
    #case "$current" in
    #  "performance") active_idx=0 ;;
    #  "balanced")    active_idx=1 ;;
    #  "power-saver") active_idx=2 ;;
    #  *)             active_idx=-1 ;;
    #esac

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
    
    #chosen=$(echo "$chosen" | sed 's/<[^>]*>//g')
    chosen="''${chosen//<i>/}"
    chosen="''${chosen//<\/i>/}"

    if [[ -n "$chosen" && "$chosen" != "$current" ]]; then
      powerprofilesctl set "$chosen"
      notify-send "Power Profile" "Switched to $chosen" -i "battery-good"
    fi
  '';
}
