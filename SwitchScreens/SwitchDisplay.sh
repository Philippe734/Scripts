#!/bin/bash

get_active_monitors()
{
    xrandr | awk '/\ connected/ && /[[:digit:]]x[[:digit:]].*+/{print $1}'
}

# Number of display connected
NumberDisplay=$(xrandr | grep " connected"  | grep "" -c)
if [ $NumberDisplay -lt 2 ]; then
    echo "single monitor: no switch"
    exit 0
fi

DisplayActive=$(get_active_monitors)

echo "Display active : $DisplayActive"

case "$DisplayActive" in
    eDP-1) notify-send "Clone"
        echo "set to clone"
        xrandr --output eDP-1 --output HDMI-2 --mode 1920x1080 ;;
    HDMI-2) notify-send "Monitor"
        echo "set to monitor"
        xrandr --output eDP-1 --mode 1920x1080 --output HDMI-2 --off ;;
    *) notify-send "TV"
        echo "set to TV"
        xrandr --output HDMI-2 --mode 1920x1080
        sleep 1s
        xrandr --output eDP-1 --off ;;
esac

exit 0
