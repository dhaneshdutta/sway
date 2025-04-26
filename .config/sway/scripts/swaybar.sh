#!/bin/bash

# Function to get media player status (with MPD support)
get_media() {
    # First try MPD if running
    if command -v mpc &>/dev/null; then
        mpc_status=$(mpc status 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$mpc_status" ]; then
            # Check if MPD is playing or paused
            if echo "$mpc_status" | grep -q "\[playing\]"; then
                current=$(mpc current 2>/dev/null)
                echo "🎵 $current"
                return
            elif echo "$mpc_status" | grep -q "\[paused\]"; then
                current=$(mpc current 2>/dev/null)
                echo "⏸️ $current"
                return
            fi
        fi
    fi
    
    # If MPD not active, try playerctl (for other players)
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

# Function to get volume level
get_volume() {
    # Try pamixer (Wayland/PipeWire)
    if command -v pamixer &>/dev/null; then
        vol=$(pamixer --get-volume 2>/dev/null)
        mute=$(pamixer --get-mute 2>/dev/null)
        if [ "$mute" == "true" ]; then
            echo "🔇 Muted"
        else
            if [ "$vol" -gt 70 ]; then
                echo "🔊 ${vol}%"
            elif [ "$vol" -gt 30 ]; then
                echo "🔉 ${vol}%"
            else
                echo "🔈 ${vol}%"
            fi
        fi
        return
    fi
    
    # Try wpctl (Wireplumber/PipeWire)
    if command -v wpctl &>/dev/null; then
        vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "[0-9.]*" | awk '{print int($1*100)}')
        mute=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "MUTED")
        if [ -n "$mute" ]; then
            echo "🔇 Muted"
        else
            if [ "$vol" -gt 70 ]; then
                echo "🔊 ${vol}%"
            elif [ "$vol" -gt 30 ]; then
                echo "🔉 ${vol}%"
            else
                echo "🔈 ${vol}%"
            fi
        fi
        return
    fi
    
    # Try pactl (PulseAudio)
    if command -v pactl &>/dev/null; then
        vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -o "[0-9]*%" | head -1 | tr -d '%')
        mute=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o "yes")
        if [ "$mute" == "yes" ]; then
            echo "🔇 Muted"
        else
            if [ "$vol" -gt 70 ]; then
                echo "🔊 ${vol}%"
            elif [ "$vol" -gt 30 ]; then
                echo "🔉 ${vol}%"
            else
                echo "🔈 ${vol}%"
            fi
        fi
        return
    fi
    
    # Try amixer (ALSA)
    if command -v amixer &>/dev/null; then
        vol=$(amixer get Master 2>/dev/null | grep -o "[0-9]*%" | head -1 | tr -d '%')
        mute=$(amixer get Master 2>/dev/null | grep -o "\[off\]" | head -1)
        if [ -n "$mute" ]; then
            echo "🔇 Muted"
        else
            if [ "$vol" -gt 70 ]; then
                echo "🔊 ${vol}%"
            elif [ "$vol" -gt 30 ]; then
                echo "🔉 ${vol}%"
            else
                echo "🔈 ${vol}%"
            fi
        fi
        return
    fi
    
    # Try sndioctl (OpenBSD)
    if command -v sndioctl &>/dev/null; then
        vol=$(sndioctl -n output.level | awk '{print int($1*100)}')
        mute=$(sndioctl -n output.mute)
        if [ "$mute" -eq 1 ]; then
            echo "🔇 Muted"
        else
            if [ "$vol" -gt 70 ]; then
                echo "🔊 ${vol}%"
            elif [ "$vol" -gt 30 ]; then
                echo "🔉 ${vol}%"
            else
                echo "🔈 ${vol}%"
            fi
        fi
        return
    fi
    
    # If we get here, no volume utility was found
    echo "🔊 N/A"
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
    volume_section="$(get_volume)"
    left_section="$(get_battery) | $(get_ram) | $(get_cpu)"
    right_section="$(get_datetime)"

    # Output: Media | Volume | Battery/RAM/CPU | Date/Time
    echo "$media_section | $volume_section | $left_section | $right_section"

    sleep 1
done
