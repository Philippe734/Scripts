#!/bin/bash
notify-send "Begin process..." "$@"
mkvmerge -o "$@.mkv" "$@"
notify-send "Over" "$@"

