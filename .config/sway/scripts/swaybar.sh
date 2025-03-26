#!/bin/bash

# Function to get media player status
get_media() {
    player_status=$(playerctl status 2>/dev/null)
    if [ "$player_status" == "Playing" ]; then
        song=$(playerctl metadata title 2>/dev/null)
        echo "🎵 $song"
    elif [ "$player_status" == "Paused" ]; then
        song=$(playerctl metadata title 2>/dev/null)
        echo "⏸️ $song"
    else
        echo "🎵 No Media"
    fi
}

# Function to get date and time
get_datetime() {
    date "+📅 %a %d %b | 🕒 %I:%M %p"
}

# Function to get battery level
get_battery() {
    level=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null)
    status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null)
    if [[ "$status" == "Charging" ]]; then
        echo "🔌 $level%"
    else
        echo "🔋 $level%"
    fi
}

# Function to get RAM usage
get_ram() {
    free_mem=$(free -m | awk '/Mem:/ {print $3}')
    total_mem=$(free -m | awk '/Mem:/ {print $2}')
    echo "🧠 $free_mem/$total_mem MB"
}

# Function to get CPU usage
get_cpu() {
    usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    echo "🔥 ${usage}%"
}

# Infinite loop for the status bar
while true; do
    media_section="$(get_media)"
    left_section="$(get_battery) | $(get_ram) | $(get_cpu)"
    right_section="$(get_datetime)"

    # Output: (Workspaces) | Media Info | Battery/RAM/CPU | Date/Time
    echo "$media_section | $left_section | $right_section"

    sleep 1
done

