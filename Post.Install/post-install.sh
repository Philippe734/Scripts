#!/bin/bash
# Opérations : post installation pour Ubuntu Mate & Xubuntu
# Philippe - 2019
# Script à déposer sur mes clés USB
# Récupère et exécute les scripts post-install pour sudo et sans sudo
# Pour l'exécuter, utiliser: bash /chemin/NomScript.sh

FILESUDO=~/post-install-sudo.sh
FILEUSER=~/post-install-user.sh
(
while [ ! -x "$FILESUDO" ]; do
    rm $FILESUDO
    wget https://www.dropbox.com/s/mydropboxID/post-install-sudo.sh -P ~
    sleep 1s
    chmod +x $FILESUDO
done
while [ ! -x "$FILEUSER" ]; do
    rm $FILEUSER
    wget https://www.dropbox.com/s/mydropboxID/post-install-user.sh -P ~
    sleep 1s
    chmod +x $FILEUSER
done
) | zenity --progress --pulsate --width=300 --text="Initialisation..." --title="Post-install" --no-cancel --auto-close

bash $FILEUSER &

pkexec env DESKTOP_SESSION=$DESKTOP_SESSION DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY bash $FILESUDO

# ne pas terminer avec exit 0

