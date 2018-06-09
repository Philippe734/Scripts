#!/bin/bash
# GUI to schedule shutdown with yad : sudo apt install yad

out=$(
yad --form --center --title="" --field="Shutdown":LBL \
    --field="Hour":NUM \
    --field="Minutes":NUM \
    --button="Shutdown -c":1 \
    --button="Schedule shutdown":2
)

ret=$?
hour=$(echo $out | cut -f 2 -d '|')
minutes=$(echo $out | cut -f 3 -d '|')

if [[ $ret -eq 1 ]]; then
    shutdown -c
    notify-send "Cancel"
else
    shutdown $hour:$minutes
    notify-send "Shutdown scheduled"
fi

exit 0

