#!/bin/bash
notify-send "Dossier..." $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
cd $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
for a in *;do
	notify-send "File..." "$a"
	mkvmerge -o "$a.mkv" "$a"
	notify-send "$a" "Done"
done
notify-send "Folder done"

