#!/bin/bash
IFS='
'
# paramètre %F : full path file
# paramètre %P : full directory path
# $@ est lié au paramètre
yad --center --text-align=center --title="Envoyer par mail" --text="Quelle qualité ?" --button="Originale":1  --button="Moyenne":2 --button="Petite":3 ; quality=$?

notify-send "Patientez..."

printf %s "$@" |
emailattachment=""
for fullfile in $@
do
    filename="${fullfile##*/}" # nom du fichier
    #yad --center --title="qualité" --entry-text="$quality" --entry
    case "$quality" in
        1) cp "$fullfile" /tmp/"$filename" ;;
        2) convert "$fullfile" -resize 1024 -quality 80% /tmp/"$filename" ;;
        3) convert "$fullfile" -resize 640 -quality 60% /tmp/"$filename" ;;
    esac

    emailattachment="$emailattachment/tmp/$filename,"
    #yad --center --title="in do" --entry-text="$emailattachment" --entry
    sleep 500ms
done
#yad --center --title="after do" --entry-text="$emailattachment" --entry
fichiersjoints=${emailattachment%?} # enlève le dernier caractère, la virgule de fin
#yad --center --title="fichierjoints" --entry-text="$fichiersjoints" --entry
thunderbird -compose attachment="'$fichiersjoints'"

exit 0
