#!/bin/bash

# This script lets the user select an image and
# set it as the desktop background on Ubuntu MATE. It copies
# the image to the /usr/share/backgrounds directory,
# updates the background setting, and recompiles the schemas.
# Philippe734 @ 2025

# Check if YAD installed
if ! command -v yad &> /dev/null; then
    pkexec bash -c "apt install yad -y"
fi

yad --title="Change background login screen" --height=150 --width=400 --fixed --text="<span foreground='blue'><b><big><big>Select your image</big></big></b></span>" --text-align=center --center --borders=20 --image='./design.png'

if [ $? = 1 ]; then
    echo "canceled"
    exit 0
fi

DEST_DIR="/usr/share/backgrounds"
SCHEMA_FILE="/usr/share/glib-2.0/schemas/30_ubuntu-mate.gschema.override"

while true; do
    # Let the user select an image
    IMAGE_PATH=$(yad --file --center --title="Select an image" --width=600 --height=400)
    
    # If no image is selected, exit
    test -z "$IMAGE_PATH" && exit 1
    
    # Check if the selected file is an image
    MIME_TYPE=$(file --mime-type -b "$IMAGE_PATH")
    if [[ $MIME_TYPE =~ ^image/ ]]; then
        break  # Exit the loop if the file is a valid image
    else
        yad --title "Error" --width=400 --height=100 --center --button=OK:0 \
            --text "The selected file is not an image. Please select a valid image file."
    fi
done

# Get the file name without modification
IMAGE_NAME=$(basename "$IMAGE_PATH")

# Final path in /usr/share/backgrounds
FINAL_IMAGE_PATH="$DEST_DIR/$IMAGE_NAME"

# Escape the apostrophes in the image path before running pkexec
ESCAPED_IMAGE_PATH=$(echo "$FINAL_IMAGE_PATH" | sed "s/'/'\\\\''/g")

# Call pkexec to execute commands as root
pkexec bash -c "

    # Copy the image and modify the schema
    cp -f \"$IMAGE_PATH\" \"$FINAL_IMAGE_PATH\"

    # Change permissions of the copied image to make it readable by others
    chmod 644 "$FINAL_IMAGE_PATH"

    # Modify the schema file to set the new background image path
    sed -i \"s|^background=.*|background='$ESCAPED_IMAGE_PATH'|\" \"$SCHEMA_FILE\"
    
    # Compile the schemas
    glib-compile-schemas /usr/share/glib-2.0/schemas/
"

# Display the final result
echo "### result:"
grep "^background=" "$SCHEMA_FILE"
echo "###"

notify-send "Done" "You should logout"

exit 0

