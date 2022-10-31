#!/bin/bash
# Opérations : post installation pour Ubuntu Mate & Xubuntu
# Philippe734 - 2019
# Ce script est uniquement sans sudo
# Fonctions avec sudo > utiliser le script post-install-sudo.sh

# Laisser la TODOlist dans sudo car faut installer yad

(
echo "10" ; sleep 0.3
echo "# Préparation des fichiers..."

# Verrou panel
wget https://www.dropbox.com/s/fqtios0eiyfh8mw/mozo-made-1.desktop -P ~
echo "20" ; sleep 0.3
mkdir --p ~/.local/share/applications
mv ~/mozo-made-1.desktop ~/.local/share/applications/unlock-panel.desktop
wget https://www.dropbox.com/s/3loxh983wtihc9r/mozo-made.desktop -P ~
echo "30" ; sleep 0.3
mv ~/mozo-made.desktop ~/.local/share/applications/lock-panel.desktop

# Raccourcis vers l'appli de dépannage
wget https://www.dropbox.com/s/n28ywniaodd9s15/depannage.desktop -P ~
mkdir --p ~/.local/share/applications
mv ~/depannage.desktop ~/.local/share/applications/depannage.desktop

# Fonds d'écran Windows 10
wget https://www.dropbox.com/s/2zp5li0p665nyd7/Wallpaper-windows10.jpg -P ~/"Images/Fonds d'écran"
echo "35" ; sleep 0.3

echo "99" ; sleep 1s
echo "100"
) | zenity --progress --title="Paramètres" --width=300 --no-cancel --auto-close

# Icones Windows 10
FILE=~/icon-win10.zip
while [ ! -f "$FILE" ]; do
    rm $FILE
    wget https://www.dropbox.com/s/a7n2vpl2ylhyygu/icon-win10.zip -P ~
    sleep 3s
done
sleep 0.3
unzip "$FILE" -d ~/.icons

# ne pas terminer avec exit 0
