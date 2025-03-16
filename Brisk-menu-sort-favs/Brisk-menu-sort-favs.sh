#!/bin/bash

# Script to sort the favorites of brisk-menu in alphabetical order.
# This script reads the current list of favorites from dconf, cleans and sorts it alphabetically
# based on the application names. It then writes the sorted list back to dconf, updating the 
# favorites in the brisk-menu. 
# Philippe734 @ 2025

# Read the current favorites list
FAVS=$(dconf read /com/solus-project/brisk-menu/favourites)

# Clean the list and convert it to separate lines
if [ -z "$FAVS" ] || [ "$FAVS" == "@as []" ]; then
    exit 1
fi

# Clean the list and convert it to separate lines
FAVS_CLEAN=$(echo "$FAVS" | tr -d "[]'" | tr ',' '\n' | sed 's/^ *//g' | sed 's/ *$//g')

# Define the directory where .desktop files are stored
DESKTOP_DIRS=("$HOME/.local/share/applications" "/usr/share/applications")

declare -A APP_MAP
APP_NAMES=()

# Loop through the favorite files and retrieve their application name
while read -r desktop_file; do
    for dir in "${DESKTOP_DIRS[@]}"; do
        if [[ -f "$dir/$desktop_file" ]]; then
            app_name=$(grep -m 1 "^Name=" "$dir/$desktop_file" | cut -d'=' -f2)
            if [[ -n "$app_name" ]]; then
                APP_MAP["$app_name"]="$desktop_file"
                APP_NAMES+=("$app_name")  # Add to the app names list
            fi
            break
        fi
    done
done <<< "$FAVS_CLEAN"

# Sort the application names while preserving spaces
TMP_SORT_FILE=$(mktemp)
printf "%s\n" "${APP_NAMES[@]}" | sort > "$TMP_SORT_FILE"

# Sorting
FAVS_SORTED=()
while IFS= read -r app; do
    FAVS_SORTED+=("${APP_MAP[$app]}")
done < "$TMP_SORT_FILE"
rm "$TMP_SORT_FILE"

# Reformat the sorted list for dconf
FAVS_NEW="[$(printf "'%s', " "${FAVS_SORTED[@]}" | sed 's/, $//')]"

# Write the sorted favorites list back to dconf
dconf write /com/solus-project/brisk-menu/favourites "$FAVS_NEW"

# Show before after
echo -e "Before:\n$FAVS"
echo -e "After:\n$FAVS_NEW"

# Kill Brisk menu
killall brisk-menu 2>/dev/null

# Reload by user
notify-send "You need to click on reload" "Brisk Menu"
exit 0
