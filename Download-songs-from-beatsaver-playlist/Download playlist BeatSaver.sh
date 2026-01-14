#!/bin/bash
# For Beat Saber
# Download all songs from a playlist .bplist file from Beat Saver
# then install it in custom levels folder of beat saber

# before use the script, set your path to install songs with:
# echo 'export BEATSABER="/Path/To/SteamLibrary/steamapps/common/Beat Saber/Beat Saber_Data/CustomLevels"' >> ~/.bashrc
# source ~/.bashrc


set -euo pipefail

# require yad
if ! command -v yad >/dev/null 2>&1; then
  echo "Installez yad : sudo apt install yad"
  exit 1
fi

# select bplist
BPLIST_FILE=$(yad --file-selection --height=500 --width=900 --fixed --title="Sélectionner la playlist .bplist à télécharger" --filename="$HOME/Téléchargements" 2>/dev/null)
[ -n "$BPLIST_FILE" ] || exit 1
[ -f "$BPLIST_FILE" ] || { echo "Fichier introuvable"; exit 1; }

# output dir: same folder, subfolder 'downloads'
base=$(basename "$BPLIST_FILE")
name="${base%.*}"
OUTDIR="$HOME/Downloads/$name"
mkdir -p "$OUTDIR"

# Beat Saber folder for extraction already set by the system environnement
# $BEATSABER

# extract hash -> songName mapping
declare -A SONGS_MAP
if command -v jq >/dev/null 2>&1; then
    while IFS="|" read -r hash songName; do
        SONGS_MAP["$hash"]="$songName"
    done < <(jq -r '.songs[] | "\(.hash)|\(.songName)"' "$BPLIST_FILE")
else
    echo "jq require tp parse .bplist"
    exit 1
fi

[ "${#SONGS_MAP[@]}" -gt 0 ] || { yad --error --text="no song found." >/dev/null 2>&1; exit 1; }

(
i=0
total=${#SONGS_MAP[@]}
for h in "${!SONGS_MAP[@]}"; do
  i=$((i+1))
  song_name="${SONGS_MAP[$h]}"
  safe_name=$(echo "$song_name" | tr -cd '[:alnum:] _-')
  out="$OUTDIR/${safe_name}.zip"
  url="https://r2cdn.beatsaver.com/${h}.zip"

  echo "[$i/$total] $url -> $out"

  if command -v wget >/dev/null 2>&1; then
    wget -c --show-progress -O "$out" "$url" || echo "Fail: $url"
  elif command -v curl >/dev/null 2>&1; then
    curl -L --fail -C - --progress-bar -o "$out" "$url" || echo "Fail: $url"
  else
    yad --error --text="wget or curl not found" >/dev/null 2>&1
    exit 1
  fi
done
) | zenity --progress --auto-close --title="Downloading..." \
        --width=400 --pulsate --auto-kill

#unzip all songs to custom level folder
for zipfile in "$OUTDIR"/*.zip; do
  foldername=$(basename "$zipfile" .zip)
  dest="$BEATSABER/$foldername"
  mkdir -p "$dest"
  unzip -o "$zipfile" -d "$dest" >/dev/null
done

exit 0

