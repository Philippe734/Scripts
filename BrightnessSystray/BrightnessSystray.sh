#!/bin/bash

# Script to add an icon in the notification area, 
# to set the brightness of the screen

# Require yad : sudo apt install yad

# Name of the screen
DisplayName='DisplayPort-1'

# set by default
xrandr --output "$DisplayName" --brightness 0.75

# set brightness
yad --notification --text="Select the brightness" --image="/Path/To/Icon.png" --menu='Set to 100%!xrandr --output '$DisplayName' --brightness 1|Set to 95%!xrandr --output '$DisplayName' --brightness 0.95|Set to 90%!xrandr --output '$DisplayName' --brightness 0.9|Set to 85%!xrandr --output '$DisplayName' --brightness 0.85|Set to 80%!xrandr --output '$DisplayName' --brightness 0.8|Set to 75%!xrandr --output '$DisplayName' --brightness 0.75|Set to 70%!xrandr --output '$DisplayName' --brightness 0.70|Set to 65%!xrandr --output '$DisplayName' --brightness 0.65|Set to 60%!xrandr --output '$DisplayName' --brightness 0.6|Set to 55%!xrandr --output '$DisplayName' --brightness 0.55|Set to 50%!xrandr --output '$DisplayName' --brightness 0.5|Set to 45%!xrandr --output '$DisplayName' --brightness 0.45|Set to 40%!xrandr --output '$DisplayName' --brightness 0.4|Set to 35%!xrandr --output '$DisplayName' --brightness 0.35|Set to 30%!xrandr --output '$DisplayName' --brightness 0.3|Quit!quit' --command="" --no-middle

exit 0

