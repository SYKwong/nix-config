{ pkgs, ... }:

let
  power-menu = pkgs.writeShellScriptBin "power-menu" ''
    # Fetch current profile to display as a message
    current=$(powerprofilesctl get)

# Get list of available profiles from the system
# We filter the 'powerprofilesctl list' output to get just the profile names
    options=$(powerprofilesctl list | awk '/^\s*[* ]\s*[a-zA-Z0-9\-]+:$/ { gsub(/^[*[:space:]]+|:$/,""); print }' 
# Use Rofi to select a profile
# The -mesg shows the active profile at the top
    chosen=$(echo "$options" | rofi -dmenu -i -p "Power Profile" \
      -mesg "<b>Active:</b> $current" \
      -theme-str 'window {width: 20em;} listview {lines: 4;}')

# If a profile was chosen, set it
    if [ -n "$chosen" ]; then
      powerprofilesctl set "$chosen"
      notify-send "Power Profile" "Switched to $chosen mode" -i power-profile
    fi
  '';
in
{
  environment.systemPackages = [ power-menu ];
}
