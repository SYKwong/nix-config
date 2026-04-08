{ pkgs, ... }:

let
  power-menu = pkgs.writeShellScriptBin "power-menu" ''
    PROFILES=("performance" "balanced" "power-saver")
    CURRENT=$(powerprofilesctl get)

    ACTIVE_INDEX=-1
    for i in "''${!PROFILES[@]}"; do
      if [[ "''${PROFILES[$i]}" == "$CURRENT" ]]; then
        ACTIVE_INDEX=$i
        break
      fi
    done

    MENU=" Performance\n Balanced\n Power Saver"

    CHOSEN=$(echo -e "$MENU" | rofi -dmenu -i -p "Current: $CURRENT" -a "$ACTIVE_INDEX" -selected-row "$ACTIVE_INDEX")
    case "$CHOSEN" in
      *Performance) powerprofilesctl set performance ;;
      *Balanced)    powerprofilesctl set balanced ;;
      *Saver)       powerprofilesctl set power-saver ;;
    esac
  '';
in
{
  environment.systemPackages = [ power-menu ];
}
