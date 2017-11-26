#!/bin/bash
notify-send "Dossier..." $CAJA_SCRIPT_SELECTED_FILE_PATHS
cd $CAJA_SCRIPT_SELECTED_FILE_PATHS
for a in *;do
	notify-send "Fichier..." "$a"
	avconv -i "$a" -c:v copy -c:a copy -sn "$a.mp4"
	notify-send "$a" "Terminé"
done
notify-send "Dossier terminé"

