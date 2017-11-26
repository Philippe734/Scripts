#!/bin/bash
notify-send "Début traitement..." "$@"
avconv -i "$@" -c:v copy -c:a copy -sn "$@.mp4"
notify-send "Terminé" "$@"

