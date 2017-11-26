#!/bin/bash
notify-send "Dossier..." $CAJA_SCRIPT_SELECTED_FILE_PATHS
cd $CAJA_SCRIPT_SELECTED_FILE_PATHS
for a in *;do
	notify-send "Fichier..." "$a"
	mkvmerge -o "$a.mkv" "$a"
	notify-send "$a" "Terminé"
done
notify-send "Dossier terminé"

