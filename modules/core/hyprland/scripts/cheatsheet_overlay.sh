#!/usr/bin/env bash

# Configuration
CHEATSHEET_FILE="$HOME/.config/hypr/scripts/cheatsheet.txt"
LAUNCHER="wofi"

# Check if file exists
if [ ! -f "$CHEATSHEET_FILE" ]; then
    notify-send "Error" "Cheatsheet file not found at $CHEATSHEET_FILE"
    exit 1
fi

# Display via Launcher
if [ "$LAUNCHER" = "wofi" ]; then
    # Adjust width/lines as needed based on content length
    cat "$CHEATSHEET_FILE" | wofi --dmenu --lines 25 --width 600 --prompt "Hyprland Cheatsheet" --location center --css "window { border: 2px solid #B4DCFF; background-color: #0C0F14; color: #f1f5f9; font-family: 'JetBrainsMono Nerd Font'; }"
elif [ "$LAUNCHER" = "rofi" ]; then
    cat "$CHEATSHEET_FILE" | rofi -dmenu -p "Cheatsheet" -theme-str 'window {width: 50%;}'
else
    notify-send "Cheatsheet" "$(cat "$CHEATSHEET_FILE")"
fi
