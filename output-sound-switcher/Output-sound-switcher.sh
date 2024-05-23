#!/bin/bash

# Script to add notification icon in panel
# list and allow to select audio output.
# Philippe734 - 2024

# Function to get a list of available audio sinks
get_audio_sinks() {
    pactl list short sinks | awk '{print $2}'
}

# Prepare audio sinks list for yad menu
prepare_menu_items() {
    sinks=$(get_audio_sinks)
    menu_items=""
    for sink in $sinks; do
        nicesink=$(echo "$sink" | awk -F. '{print $NF}')
        menu_items+="$nicesink!pactl set-default-sink $sink|"
    done
    echo "$menu_items|Quit!quit"
}

# Display available audio sinks and prompt user to select one
select_audio_sink() {
    menu_items=$(prepare_menu_items)
    selected_sink=$(yad --notification --text="Select audio output" --image="audio-speakers" --menu="$menu_items" --command="" --no-middle &
    YAD_PID=$!
    echo $YAD_PID > /tmp/choixsortieaudioyad_pid
    )   
}

# Call the function to select an audio sink
select_audio_sink

exit 0

