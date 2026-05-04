{ pkgs, ... }:

let
  rofi-power-menu = pkgs.writeShellScriptBin "rofi-power-menu" ''
    current=$(powerprofilesctl get)
    options="performance\nbalanced\npower-saver"
   
    chosen=$(echo -e "''$options" | rofi -dmenu \
      -i \
      -p "Power Profile" \
      -mesg "Current: ''$current" \
      -theme-str 'window {width: 20em;} listview {lines: 3;}')

# Apply the profile if a choice was made
    if [[ -n "''$chosen" ]]; then
      powerprofilesctl set "''$chosen"
      notify-send "Power Profile" "Switched to ''$chosen" -i "battery-good"
    fi
  '';
in
{
  environment.systemPackages = [ rofi-power-menu ];
}
