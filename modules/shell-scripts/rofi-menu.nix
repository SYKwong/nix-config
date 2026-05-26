{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "rofi-menu";

  runtimeInputs = with pkgs; [
    rofi
    coreutils
    gnused
    findutils
    impala
    bluetui
    wiremix
  ];

  text = ''
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
        rofi-profile-menu ;;
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
}
