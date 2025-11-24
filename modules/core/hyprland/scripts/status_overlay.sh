#!/usr/bin/env bash

# --- Configuration ---
# Set this to your preferred launcher: wofi, rofi, or fuzzel
LAUNCHER="wofi" 

# --- Data Collection ---

# 1. Time & Date
TIME=$(date '+%H:%M')
DATE=$(date '+%A, %B %d')

# 2. Wi-Fi Status (using nmcli)
if command -v nmcli &> /dev/null; then
    WIFI_STATUS=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2)
    if [ -n "$WIFI_STATUS" ]; then
        WIFI_INFO="  Connected: $WIFI_STATUS"
    else
        WIFI_INFO="睊  Disconnected"
    fi
else
    WIFI_INFO="  (nmcli not found)"
fi

# 3. Battery Status (using upower)
if command -v upower &> /dev/null; then
    BATTERY_DEV=$(upower -e | grep 'BAT')
    if [ -n "$BATTERY_DEV" ]; then
        BATTERY_PERCENT=$(upower -i "$BATTERY_DEV" | grep percentage | awk '{print $2}')
        BATTERY_STATE=$(upower -i "$BATTERY_DEV" | grep state | awk '{print $2}')
        BATTERY_INFO="  Battery: $BATTERY_PERCENT ($BATTERY_STATE)"
    else
        BATTERY_INFO="  No Battery"
    fi
else
    BATTERY_INFO="  (upower not found)"
fi

# 4. VPN Status (checking active connections or specific interfaces)
VPN_INFO="  VPN: Disconnected"
if command -v nmcli &> /dev/null; then
    # Check for any active connection that looks like a VPN (tun, wireguard, vpn)
    VPN_ACTIVE=$(nmcli -t -f TYPE,NAME connection show --active | grep -E 'vpn|wireguard|tun' | cut -d: -f2 | head -n1)
    if [ -n "$VPN_ACTIVE" ]; then
        VPN_INFO="  VPN: Connected ($VPN_ACTIVE)"
    fi
fi

# --- Formatting for Launcher ---
# We'll feed these lines into the launcher. 
# You can customize the icons and layout.

MENU_CONTENT="$TIME  |  $DATE
$WIFI_INFO
$BATTERY_INFO
$VPN_INFO"

# --- Display Overlay ---

if [ "$LAUNCHER" = "wofi" ]; then
    # Wofi configuration:
    # -d: dmenu mode (read from stdin)
    # -L 4: 4 lines high
    # -W 400: 400px wide
    # -p "System Status": Prompt
    # --location top_right: Postion (adjust as needed)
    echo "$MENU_CONTENT" | wofi --dmenu --lines 5 --width 400 --prompt "System Status" --location top_right --css "window { border: 2px solid #B4DCFF; background-color: #0C0F14; color: #f1f5f9; }"
elif [ "$LAUNCHER" = "rofi" ]; then
    echo "$MENU_CONTENT" | rofi -dmenu -p "System Status" -theme-str 'window {width: 30%;}'
elif [ "$LAUNCHER" = "fuzzel" ]; then
    echo "$MENU_CONTENT" | fuzzel --dmenu --width 40 --lines 5 --prompt "System Status: "
else
    notify-send "Status Overlay" "$MENU_CONTENT"
fi
