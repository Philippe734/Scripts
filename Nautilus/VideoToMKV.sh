#!/bin/bash
notify-send "Début traitement..." "$@"
mkvmerge -o "$@.mkv" "$@"
notify-send "Terminé" "$@"

