{ pkgs, ... }:

let
  rofi-power-options = pkgs.writeShellScriptBin "rofi-power-options" ''
    current=$(powerprofilesctl get)
    options="performance\nbalanced\npower-saver"
   
    chosen=$(echo -e "''$options" | rofi -dmenu \
      -i \
      -p "Power Profile" \
      -mesg "Current: ''$current" \
      -theme-str 'window {width: 20em;} listview {lines: 3;}')

    if [[ -n "''$chosen" ]]; then
      powerprofilesctl set "''$chosen"
      notify-send "Power Profile" "Switched to ''$chosen" -i "battery-good"
    fi
  '';

  rofi-power-menu = pkgs.writeShellScriptBin "rofi-power-menu" ''
    options="Shutdown\nSuspend\nHibernate\nReboot\nLog Out\nLock"

    chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu:")
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
    rofi-power-options
    rofi-power-menu
  ];
}
