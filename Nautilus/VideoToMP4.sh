#!/bin/bash
notify-send "Begin process..." "$@"
avconv -i "$@" -c:v copy -c:a copy -sn "$@.mp4"
notify-send "Over" "$@"

