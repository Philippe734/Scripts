#!/bin/bash
# convert all files in a folder to MKV without encode.
notify-send "Folder..." $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
cd $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
for a in *;do
	notify-send "File..." "$a"
	mkvmerge -o "$a.mkv" "$a"
	notify-send "$a" "Done"
done
notify-send "Folder done"

