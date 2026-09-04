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
        -kb-remove-to-eol "" \
        -kb-accept-entry "Return,KP_Enter" \
        -kb-row-up "Up,Control+k" \
        -kb-row-down "Down,Control+j" \
        -kb-cancel "Escape" \
        -scroll-method 1 \
        -theme-str '
            * {
                background:                  rgba(30, 30, 46, 80%);
                background-color:            transparent;
                foreground:                  #cdd6f4;
                text-color:                  #cdd6f4;
                border-color:                #b4befe;
                separatorcolor:              transparent;

                normal-background:           transparent;
                normal-foreground:           #cdd6f4;
                alternate-normal-background: transparent;
                alternate-normal-foreground: #cdd6f4;
                selected-normal-background:  rgba(108, 112, 134, 60%);
                selected-normal-foreground:  #ffffff;

                active-background:           transparent;
                active-foreground:           #b4befe;
                alternate-active-background: transparent;
                alternate-active-foreground: #b4befe;
                selected-active-background:  rgba(108, 112, 134, 60%);
                selected-active-foreground:  #ffffff;

                urgent-background:           transparent;
                urgent-foreground:           #f38ba8;
                alternate-urgent-background: transparent;
                alternate-urgent-foreground: #f38ba8;
                selected-urgent-background:  #f38ba8;
                selected-urgent-foreground:  #1e1e2e;

                font:                        "JetBrainsMono Nerd Font 13";
            }

            window {
                width:            1100px;
                location:         center;
                anchor:           center;
                border:           2px;
                border-radius:    12px;
                border-color:     #b4befe;
                background-color: rgba(30, 30, 46, 80%);
            }

            mainbox {
                orientation: vertical;
                padding:     14px;
                children:    [ inputbar, listview ];
            }

            inputbar {
                padding:  0px 0px 10px 0px;
                spacing:  8px;
                children: [ prompt, entry ];
            }

            prompt {
                text-color: #b4befe;
                margin:     0px 8px 0px 0px;
            }

            entry {
                text-color: #cdd6f4;
            }

            listview {
                columns:       1;
                lines:         15;
                spacing:       6px;
                cycle:         true;
                fixed-height:  false;
                scrollbar:     false;
                border:        0px;
                border-color:  transparent;
            }

            element {
                padding:       6px 12px;
                border-radius: 8px;
                cursor:        pointer;
            }

            element normal.normal {
                background-color: transparent;
                text-color:       #cdd6f4;
            }

            element alternate.normal {
                background-color: transparent;
                text-color:       #cdd6f4;
            }

            element selected.normal {
                background-color: rgba(108, 112, 134, 60%);
                text-color:       #ffffff;
            }

            element normal.active {
                background-color: rgba(180, 190, 254, 25%);
                text-color:       #b4befe;
            }

            element alternate.active {
                background-color: rgba(180, 190, 254, 25%);
                text-color:       #b4befe;
            }

            element selected.active {
                background-color: rgba(108, 112, 134, 60%);
                text-color:       #ffffff;
            }

            element-text {
                background-color: transparent;
                text-color:       inherit;
                cursor:           inherit;
            }

            element-icon {
                enabled: false;
            }

            num-filtered-rows { enabled: false; }
            num-rows { enabled: false; }

            error-message {
                padding:          16px;
                border:           2px;
                border-radius:    12px;
                border-color:     #f38ba8;
                background-color: #1e1e2e;
            }

            textbox {
                text-color:       #f38ba8;
            }
        ' > /dev/null

  '';
}
