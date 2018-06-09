#!/bin/bash
# GUI to schedule shutdown with yad : sudo apt install yad

sortie=$(
yad --form --center --title="" --field="Shutdown":LBL \
    --field="Heure":NUM \
    --field="Minutes":NUM \
    --button="Shutdown -c":1 \
    --button="Planifier l'arrêt":2
)

ret=$?
heure=$(echo $sortie | cut -f 2 -d '|')
minutes=$(echo $sortie | cut -f 3 -d '|')

if [[ $ret -eq 1 ]]; then
    shutdown -c
    notify-send "Annulé"
else
    shutdown $heure:$minutes
    notify-send "Arrrêt planifié"
fi

exit 0

