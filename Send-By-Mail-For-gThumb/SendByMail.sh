#!/bin/bash
IFS='
'
# set %F when focus the script in gThumb
# yad is required: sudo apt install yad
yad --center --text-align=center --title="Send by mail" --text="Which quality ?" --button="Original":1  --button="Medium":2 --button="Small":3 ; quality=$?

notify-send "Process..."

printf %s "$@" |
emailattachment=""
for fullfile in $@
do
    filename="${fullfile##*/}" # file name
    case "$quality" in
        1) cp "$fullfile" /tmp/"$filename" ;;
        2) convert "$fullfile" -resize 1024 -quality 80% /tmp/"$filename" ;;
        3) convert "$fullfile" -resize 640 -quality 60% /tmp/"$filename" ;;
    esac

    emailattachment="$emailattachment/tmp/$filename,"
    sleep 500ms
done
fichiersjoints=${emailattachment%?} # remove the last character, the comma at the end
thunderbird -compose attachment="'$fichiersjoints'"

exit 0
