#!/usr/bin/env bash

# Setup directory and filename
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"

# Logic: Manual Selection vs. Smart Auto-Detection
if [ "$1" = "--select" ]; then
    # MANUAL MODE: Use slurp to get user-defined geometry
    GEOM=$(slurp) || exit
    MODE="Manual Selection"
else
    # SMART MODE: Use hyprctl to detect window/fullscreen state
    WINDOW_DATA=$(hyprctl activewindow -j)
    
    if [ "$(echo "$WINDOW_DATA" | jq -r '.address')" = "null" ]; then
        # No window: Capture focused monitor
        MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
        GEOM_ARG="-o $MONITOR"
        MODE="Monitor (No Window)"
    else
        IS_FULLSCREEN=$(echo "$WINDOW_DATA" | jq -r '.fullscreen')
        if [ "$IS_FULLSCREEN" = "true" ]; then
            MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
            GEOM_ARG="-o $MONITOR"
            MODE="Fullscreen"
        else
            GEOM=$(echo "$WINDOW_DATA" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
            MODE="Windowed"
        fi
    fi
fi

# Execution: Take the shot
# We use ${GEOM_ARG} if it's set (for -o), otherwise we use -g "$GEOM"
if [ -n "$GEOM_ARG" ]; then
    grim $GEOM_ARG "$FILE"
else
    grim -g "$GEOM" "$FILE"
fi

# Clipboard and Notification
wl-copy < "$FILE"
notify-send "Screenshot Captured" "Mode: $MODE\nSaved to $FILE" -i camera-photo
