#!/bin/bash
# Opérations : post installation pour Ubuntu Mate & Xubuntu
# Philippe - 2019
# Script à déposer sur mes clés USB
# Récupère et exécute les scripts post-install pour sudo et sans sudo
# Pour l'exécuter, utiliser: bash /chemin/post-install.sh

FILESUDO=~/post-install-sudo.sh
FILEUSER=~/post-install-user.sh
chmod +x $FILESUDO
chmod +x $FILEUSER

bash $FILEUSER &

pkexec env DESKTOP_SESSION=$DESKTOP_SESSION DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY bash $FILESUDO

# ne pas terminer avec exit 0
