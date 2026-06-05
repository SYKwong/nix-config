{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "rofi-keybinds";

  runtimeInputs = with pkgs; [
    bash
    coreutils
    hyprland
    rofi
    gawk
    gnused
    libnotify
    procps
  ];

  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    raw_binds=$(hyprctl binds)

    list_items=$(gawk '
        /modmask:/ {
            match($0, /modmask:[ \t]*([0-9]+)/, m);
            mask = m[1];
            
            if      (mask == "0")   mod = "";
            else if (mask == "1")   mod = "SHIFT";
            else if (mask == "4")   mod = "CTRL";
            else if (mask == "5")   mod = "CTRL + SHIFT";
            else if (mask == "8")   mod = "ALT";
            else if (mask == "9")   mod = "ALT + SHIFT";
            else if (mask == "12")  mod = "CTRL + ALT";
            else if (mask == "64")  mod = "SUPER";
            else if (mask == "65")  mod = "SUPER + SHIFT";
            else if (mask == "68")  mod = "SUPER + CTRL";
            else if (mask == "72")  mod = "SUPER + ALT";
            else if (mask == "73")  mod = "SUPER + ALT + SHIFT";
            else {
                if (match($0, /\(([^)]+)\)/, t)) {
                    mod = t[1];
                    if (mod == "none") mod = "";
                } else {
                    mod = "MOD(" mask ")";
                }
            }
        }
        /key:/ {
            sub(/^[ \t]*key:[ \t]*/, "");
            key = $0;

            if (match(key, /^XF86(Audio|MonBrightness)/)) {
                mod = ""; key = ""; next;
            }

            if      (key == "mouse:272")   key = "󰍽 LMB ";
            else if (key == "mouse:273")   key = "󰍽 RMB";
            else if (key == "mouse_down")  key = "󰍽 Scroll Down";
            else if (key == "mouse_up")    key = "󰍽 Scroll Up";
        }
        /description:/ {
            sub(/.*description:[ \t]*/, "");
            desc = $0;
            
            if (mod != "") {
                keybind = mod " + " key;
            } else {
                keybind = key;
            }
            
            if (desc != "" && keybind != "") {
                printf "%-35s %s\n", keybind, desc;
            }
            
            mod = ""; key = ""; keybind = "";
        }
    ' <<< "$raw_binds")

    if [ -z "$list_items" ]; then
        notify-send -h boolean:transient:true "Hyprland Keybinds" "No documented keybinds found. Reload your config!"
        exit 0
    fi

    printf "%s\n" "$list_items" | rofi \
        -dmenu \
        -i \
        -p "󰍉 Keybind Cheat Sheet " \
        -theme-str '
            window {
                width: 1100px;
                location: center;
                anchor: center;
            }

            mainbox {
                orientation: vertical;
                padding: 10px;
                children: [ inputbar, listview ];
            }

            listview {
                columns: 1;
                lines: 15;
                spacing: 22px;
                cycle: true;
                fixed-height: false;
                scrollbar: false;
            }

            element {
                orientation: horizontal;
                padding: 6px 16px;
                border-radius: 4px;
            }

            element-icon {
                enabled: false;
            }

            element-text {
                expand: true;
                font: "Monospace 15";
                horizontal-align: 0.0;
                margin: 0px;
                padding: 0px;
            }

            num-filtered-rows { enabled: false; }
            num-rows { enabled: false; }
        ' > /dev/null

  '';
}
