#!/bin/bash

#make a standard zenity title; intentionally unquoted throughout
title="--title MD5checksums"

#feed answers into zentiy list; but also store answer back from the list
checksum=$( (

#make sure list has time to show up below progress bar
sleep 0.5

#zenity progress bar hack; echo is required to begin pulsating
while echo; do sleep 10; done |
    zenity --progress --pulsate $title \
        --text "Calculating. May take some time..." \
        --width 320 &
progressbar="$!"

for file in "$@"
do
    #only process normal files
    if [ -f "$file" ]; then
        md5sum "$file" | cut -c-32
        basename "$file"
    fi
done
kill "$progressbar"
) | zenity --list $title --text "" \
    --height 360 --width 420 \
    --column "MD5" --column "File"
)

#display answer if one was picked; maybe good for copying and pasting
if [ -n "$checksum" ]; then
    zenity --info $title --text "$checksum"
fi

#End of File
