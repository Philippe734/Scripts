#!/bin/bash
notify-send "Folder..." $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
cd $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
for a in *;do
	notify-send "File..." "$a"
	avconv -i "$a" -c:v copy -c:a copy -sn "$a.mp4"
	notify-send "$a" "Done"
done
notify-send "Folder done"

