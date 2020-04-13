#!/bin/bash
# Opérations : post installation pour Ubuntu Mate & Xubuntu
# Philippe734 - 2019
# Récupérer ce script: wget https://www.dropbox.com/s/mydropboxID/post-install-user.sh -P ~
# Ce script est uniquement sans sudo
# Fonctions avec sudo > utiliser le script post-install-sudo.sh

# pour tester :

#echo "Test terminé"
#exit 0

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

wget https://www.dropbox.com/s/2zp5li0p665nyd7/Wallpaper-windows10.jpg -P ~/"Images/Fonds d'écran"
echo "35" ; sleep 0.3


# correction du thème pour LibreOffice
# car l'apparence de LibreOffice est défectueuse avec le thème Materia
specifictheme="Clearlooks"
find /usr/share/applications -name libreoffice* | xargs -i cp {} ~/.local/share/applications
find ~/.local/share/applications -name libreoffice* | xargs sed -i "s/Exec=/Exec=env GTK_THEME=$specifictheme /g"
echo "50" ; sleep 0.3

# icones Windows 10
FILE=~/2NcMwiu
while [ ! -f "$FILE" ]; do
    rm $FILE
    wget https://bit.ly/2NcMwiu -P ~
    sleep 1s
done
echo "80" ; sleep 0.3
unzip ~/2NcMwiu -d ~/.icons
echo "99" ; sleep 2s
echo "100"
) | zenity --progress --title="Paramètres" --width=300 --no-cancel --auto-close

# ne pas terminer avec exit 0
