#!/bin/bash

get_active_monitors()
{
    xrandr | awk '/\ connected/ && /[[:digit:]]x[[:digit:]].*+/{print $1}'
}

monitor="eDP-1"
TV="HDMI-1"

# Number of display connected
NumberDisplay=$(xrandr | grep " connected"  | grep "" -c)
if [ $NumberDisplay -lt 2 ]; then
    echo "single monitor: no switch"
    exit 0
fi

DisplayActive=$(get_active_monitors)

echo "Display active : $DisplayActive"

case "$DisplayActive" in
    "$monitor") notify-send "Clone"
        echo "set to clone"
        xrandr --output "$monitor" --output "$TV" --mode 1920x1080 ;;
    "$TV") notify-send "Monitor"
        echo "set to monitor"
        xrandr --output "$monitor" --mode 1920x1080 --output "$TV" --off ;;
    *) notify-send "TV"
        echo "set to TV"
        xrandr --output "$TV" --mode 1920x1080
        sleep 1s
        xrandr --output "$monitor" --off ;;
esac

exit 0
