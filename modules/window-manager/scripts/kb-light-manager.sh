#!/usr/bin/env bash

# Usage: kb-light-manager <action> <backend> <vid> <pid>
ACTION="$1"   # off | on
VID="$2"      # e.g., 32ac
PID="$3"      # e.g., 0012

# Generate a unique state file per device to avoid collisions
# Example: /tmp/kb_state_qmk_32ac_0012
STATE_FILE="/tmp/kb_state_${VID}_${PID}"

if [ "$ACTION" = "off" ]; then
    # Capture real hardware state and save to the unique file
   CURRENT=$(qmk_hid --vid "$VID" --pid "$PID" via --backlight | grep -o '[0-9]\+' | head -n 1)
    echo "$CURRENT" > "$STATE_FILE"
    qmk_hid --vid "$VID" --pid "$PID" via --backlight 0
else
    # Restore from the unique file, default to 100
    VAL=$(cat "$STATE_FILE" 2>/dev/null || echo 100)
    qmk_hid --vid "$VID" --pid "$PID" via --backlight "$VAL"
fi
