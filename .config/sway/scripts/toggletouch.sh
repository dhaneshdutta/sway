#!/bin/bash

TOUCHSCREEN="1267:9385:ELAN0732:00_04F3:24A9"

# Check if the touchscreen is enabled
if swaymsg -t get_inputs | grep -A5 "\"identifier\": \"$TOUCHSCREEN\"" | grep -q "\"send_events\": \"enabled\""; then
    swaymsg input "$TOUCHSCREEN" events disabled
    notify-send "Touchscreen Disabled"
else
    swaymsg input "$TOUCHSCREEN" events enabled
    notify-send "Touchscreen Enabled"
fi

