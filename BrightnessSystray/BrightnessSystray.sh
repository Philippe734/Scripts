#!/bin/bash

# Script to add an icon in the notification area, 
# to set the screen's brightness, by right clic

# Require yad : sudo apt install yad

get_active_monitors()
{
    xrandr | awk '/\ connected/ && /[[:digit:]]x[[:digit:]].*+/{print $1}'
}

# Name of the screen
DisplayName=$(get_active_monitors)

# set by default
xrandr --output "$DisplayName" --brightness 0.75

# set brightness
yad --notification --text="Select the brightness" --image="/Path/To/Icon.png" --menu='Set the brightness|100%!xrandr --output '$DisplayName' --brightness 1|95%!xrandr --output '$DisplayName' --brightness 0.95|90%!xrandr --output '$DisplayName' --brightness 0.9|85%!xrandr --output '$DisplayName' --brightness 0.85|80%!xrandr --output '$DisplayName' --brightness 0.8|75%!xrandr --output '$DisplayName' --brightness 0.75|70%!xrandr --output '$DisplayName' --brightness 0.70|65%!xrandr --output '$DisplayName' --brightness 0.65|60%!xrandr --output '$DisplayName' --brightness 0.6|55%!xrandr --output '$DisplayName' --brightness 0.55|50%!xrandr --output '$DisplayName' --brightness 0.5|45%!xrandr --output '$DisplayName' --brightness 0.45|40%!xrandr --output '$DisplayName' --brightness 0.4|35%!xrandr --output '$DisplayName' --brightness 0.35|30%!xrandr --output '$DisplayName' --brightness 0.3|Quit!quit' --command="" --no-middle

exit 0
