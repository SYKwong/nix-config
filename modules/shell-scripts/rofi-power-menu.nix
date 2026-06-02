{ pkgs, ... }:


pkgs.writeShellApplication {
  name = "rofi-power-menu";

  runtimeInputs = with pkgs; [
    rofi
    systemd
    procps
    hyprlock
  ];

  text =  ''
    options="󰐥 Shutdown\n󰒲 Suspend\n󰤁 Hibernate\n󰜉 Reboot\n󰍃 Logout\n Lock"

    chosen=$(echo -e "$options" | rofi -dmenu \
      -i \
      -theme-str '
        inputbar {
          children: [ "textbox-prompt-colon", "entry" ];
          spacing: 8px;
        }

        /* Use a Nerd Font magnifying glass glyph as the prompt */
        textbox-prompt-colon {
          enabled: true;
          expand: false;
          str: " ";
          text-color: @text;
          background-color: @transparent;
          font: "JetBrainsMono Nerd Font 12";
        }
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
        loginctl terminate-user "$USER" ;;
      " Lock")
        pidof hyprlock || hyprlock ;; 
      *)
        exit 1 ;;
    esac
  '';
}
