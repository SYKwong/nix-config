{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "rofi-wallpaper-picker";

  runtimeInputs = with pkgs; [
    bash
    coreutils
    findutils
    imagemagick
    rofi
    swaybg
    libnotify
    procps
  ];

  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    WALLPAPER_DIR="$HOME/Wallpaper"
    CACHE_DIR="$WALLPAPER_DIR/.thumbnail"
    CURRENT_LINK="$WALLPAPER_DIR/current_wallpaper"

    mkdir -p "$CACHE_DIR"

    generate_thumb() {
        local img="$1"
        local base
        base=$(basename "$img")
        local thumb="$CACHE_DIR/''${base}.jpg"

        if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
            magick "$img" \
                -thumbnail "640x360^" \
                -gravity center \
                -extent 640x360 \
                -quality 85 \
                "$thumb"
        fi

        printf "%s\0icon\x1f%s\n" "$base" "$thumb"
    }

    export -f generate_thumb
    export CACHE_DIR

    shopt -s nullglob
    mapfile -t files < <(
      printf '%s\n' "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp} 2>/dev/null |
      sort
    )

    mapfile -t files < <(
      printf "%s\n" "''${files[@]}" | sort
    )

    [ ''${#files[@]} -eq 0 ] && exit 0

    current_base=""
    
    if [ -L "$CURRENT_LINK" ]; then
        current_target="$(readlink -f "$CURRENT_LINK")"
        current_base="$(basename "$current_target")"
    fi
    
    selected_row=0
    
    for i in "''${!files[@]}"; do
        if [ "$(basename "''${files[$i]}")" = "$current_base" ]; then
            selected_row="$i"
            break
        fi
    done

    selection_base=$(
        for f in "''${files[@]}"; do
          generate_thumb "$f"
        done | \
        rofi \
            -dmenu \
            -scroll-method 1 \
            -p "Select Wallpaper" \
            -selected-row "$selected_row" \
            -theme-str '
                window {
                    width: 1100px;
                    height: 400px;
                    location: center;
                    anchor: center;
                    orientation: horizontal;
                }

                mainbox {
                    orientation: horizontal;
                    children: [ left-box, right-box ];
                }

                left-box {
                    orientation: vertical;
                    width: 450px;
                    expand: false;
                    children: [ listview ];
                }

                right-box {
                    orientation: vertical;
                    padding: 10px;
                    width: 640px;
                    expand: true;
                    children: [ icon-current-entry ];
                }

                icon-current-entry {
                    size: 640px;
                    horizontal-align: 1.0;
                    vertical-align: 0.5;
                    expand: true;
                }

                listview {
                    columns: 1;
                    lines: 10;
                    spacing: 4px;
                    cycle: true;
                    fixed-height: true;
                }

                element {
                    orientation: horizontal;
                    padding: 8px 8px;
                    border-radius: 4px;
                }

                element-icon {
                    enabled: false;
                }

                element-text {
                    enabled: true;
                    vertical-align: 0.5;
                }
            '
    )

    [ -z "$selection_base" ] && exit 0

    FULL_PATH="$WALLPAPER_DIR/$selection_base"

    set_wallpaper() {
        local target_img="$1"

        ln -sfn "$(basename "$target_img")" "$CURRENT_LINK"

        pkill swaybg || true
        swaybg -m fill -i "$CURRENT_LINK" &

        notify-send -h boolean:transient:true "Wallpaper changed"
    }

    if [ -f "$FULL_PATH" ]; then
        set_wallpaper "$FULL_PATH"
    else
        for f in "''${files[@]}"; do
            if [ "$(basename "$f")" = "$selection_base" ]; then
                set_wallpaper "$f"
                break
            fi
        done
    fi
  '';
}
