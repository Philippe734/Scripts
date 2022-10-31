#!/bin/bash
# Opérations : post installation pour Ubuntu Mate & Xubuntu
# À exécuter avec: pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY bash /chemin/script.sh
# Philippe734 - 2019
# Ce script est uniquement avec SUDO
# Pour actions sans sudo > utiliser le script post-install-user.sh

(
sudo apt update

# Choix des paramètres
while [ $(dpkg-query -W -f='${Status}' yad 2>/dev/null | grep -c "ok installed") == "0" ]; do
    sudo apt install yad -y
    sleep 1s
done
) | zenity --progress --pulsate --width=300 --text="Préparation de l'interface..." --title="Configuration" --no-cancel --auto-close

# Mémo perso d'actions à faire après installation
memo=$(yad --fixed --no-buttons --title="Mémo" --geometry=350x300+50+50 --list --text="" --checklist --separator=":" --column="Cocher" --column="Actions" \
false "01. Résolution affichage" \
false "02. Fond d'écran" \
false "26. Activer firewall" \
false "26. Verrouiller panel" \
false "04. Disable autorun déjà" \
false "05. Disable autorun welcome" \
false "06. Préfs caja extension" \
false "07. Redmond" \
false "08. Indicateur d'activité panel" \
false "25. Vérifier icones" \
false "26. Police Noto sans 10" \
false "27. winecfg" \
false "15. Tester updates.sh" \
false "23. Langue FR" \
false "22. Thème et wallpaper windows" \
false "20. Privacy Firefox" \
false "21. uBlock Firefox" \
false "20. Check wifi" \
false "28. Style onglets LibreOffice" \
false "09. Liens apps panel" \
false "10. Délai 500 survol du Menu" \
false "09. Autorun updates.sh" \
false "11. Pilotes additionnels" \
false "16. Mettre à jour + keep config" \
false "12. Lien docs Windows" \
false "13. Cacher partition système" \
false "14. Automount partition Windows" \
false "30. Icones sur le bureau" \
false "31. Corbeille sur le bureau" \
false "32. Météo" \
false "33. Check camera cheese" \
false "34. Modifier variante Lisez-moi" \
false "35. Indicateurs batterie" \
false "36. Ajouter Dock panel" \
false "37. Sync heure windows" \
false "38. Notif coco bas droite" \
false "39. Gnome Dash to panel" \
false "40. Gnome Arc Menu" \
false "41. Désactiver mdp fin veille" \
false "42. Plymouth" \
false "43. Date & heure" \
false "46. Aspect Pluma" \
false "99. Remove scripts files" \
false "45. Corriger Grub EFI" ) &

parametres=$(yad --fixed --width=300 --button="OK" --title="Paramètres" --height=300 --center --list --text="" --checklist --separator=":" --column="Cocher" --column="Options" false "Dual-boot Windows" false "PPA LibreOffice" false "Lutris wine")

(
# Désactive le rapport de crash
echo "10" ; sleep 0.3
echo "# Configuration du système en cours... (disable apport)"
sudo rm /var/crash/*
sudo sed -i 's/enabled=1/enabled=0/' /etc/default/apport
sudo systemctl disable apport.service
sudo systemctl mask apport.service

# Variante et version
vers=$(lsb_release -rs)
if [ "$DESKTOP_SESSION" == "mate" ];then
    variante="Ubuntu Mate $vers"
elif [ "$DESKTOP_SESSION" == "xubuntu" ];then
    variante="Xubuntu $vers"
else
    variante="Ubuntu $vers"
fi

# Modif swap qd 5% ram restante
echo vm.swappiness=5 | sudo tee /etc/sysctl.conf

# Désactive les mises à jour backports
sudo sed -i '/-backports/{s/^/# /}' /etc/apt/sources.list

# LibreOffice PPA et thème
if [[ $parametres == *"PPA"* ]];then
    sudo add-apt-repository ppa:libreoffice/ppa -y
fi

echo "# Configuration du système en cours... (apt update)"
echo "20" ; sleep 0.3

# Grub optimisé
echo "# Configuration du système en cours... (theme grub)"
wget https://github.com/Philippe734/poly-light-grub2-theme/archive/master.zip ; sleep 1s
echo "22" ; sleep 0.3
unzip master.zip ; sleep 1s
echo "24" ; sleep 0.3
rm master.zip
sudo mkdir -p /boot/grub/themes
sudo mv poly-light-grub2-theme-master /boot/grub/themes/poly-light
echo "GRUB_THEME=/boot/grub/themes/poly-light/theme.txt" | sudo tee -a /etc/default/grub
if [[ $parametres == *"Windows"* ]];then
    # Afficher menu Grub pendant 5 seconde
    # GRUB_TIMEOUT_STYLE=menu
    # GRUB_TIMEOUT=5
    sudo sed -i 's/^\(GRUB_TIMEOUT_STYLE=\).*/\1menu/' /etc/default/grub
    sudo sed -i 's/^\(GRUB_TIMEOUT=\).*/\15/' /etc/default/grub
    echo "26" ; sleep 0.3
    sudo os-prober
else
    # Cacher Grub
    sudo sed -i 's/^\(GRUB_TIMEOUT_STYLE=\).*/\1hidden/' /etc/default/grub
    sudo sed -i 's/^\(GRUB_TIMEOUT=\).*/\10/' /etc/default/grub
    echo "26" ; sleep 0.3
fi
echo "# Configuration du système en cours... (update grub)"
sudo update-grub
echo "30" ; sleep 0.3

# Mises à jour silencieuses
echo "# Configuration du système en cours... (updates.sh)"
FILE=~/updates.sh
while [ ! -x "$FILE" ]; do
    rm $FILE
    #wget .../updates.txt -O $FILE
    sleep 1s
    chmod +x $FILE
done
sudo mv $FILE /opt/updates.sh
echo 'utilisateur ALL=NOPASSWD: /opt/updates.sh' | sudo EDITOR='tee -a' visudo -f /etc/sudoers.d/custom
echo "40" ; sleep 0.3

# Applis en +
echo "# Configuration du système en cours... (applis en +)"
sudo apt-get install git mate-dock-applet gthumb gnome-software thunderbird 'plymouth-theme*' -y
sudo apt remove evolution -y
echo "42" ; sleep 0.3

# Thème Materia
echo "# Configuration du système en cours... (thème)"
wget https://github.com/nana-4/materia-theme/archive/v20190315.tar.gz -P ~
cd ~
tar -xzf v20190315.tar.gz -C /tmp
cd /tmp/materia-theme-20190315
sudo ./install.sh
cd ~
rm -rf /tmp/materia-theme-20190315
rm v20190315.tar.gz
echo "50" ; sleep 0.3

# Appli de dépannage
echo "# Configuration du système en cours... (dw)"
wget https://www.dwservice.net/download/dwagent_x86.sh -P /opt
sleep 1s
chmod +x /opt/dwagent_x86.sh
echo "50" ; sleep 0.3

# Icones Flat Remix
echo "# Configuration du système en cours... (icones en +)"
wget https://launchpad.net/~noobslab/+archive/ubuntu/icons/+files/flat-remix-icons_1.58r1~bionic~NoobsLab.com_all.deb -P ~ ; sleep 2s
echo "60" ; sleep 0.3
sudo dpkg -i ~/flat-remix-icons_1.58r1~bionic~NoobsLab.com_all.deb
echo "70" ; sleep 0.3
cd ~
rm flat-remix-icons_1.58r1~bionic~NoobsLab.com_all.deb

# Besoin wine
if [[ $parametres == *"wine"* ]];then
    echo "# Configuration du système en cours... (wine)"
    echo "74" ; sleep 0.3
    sudo add-apt-repository ppa:lutris-team/lutris -y
    sudo apt update
    sudo apt install lutris -y
    sleep 1s
fi
echo "80" ; sleep 0.3

echo "# Terminé"
echo "99" ; sleep 1m
) | yad --progress --title="Information" --width=400 --height=50 --no-buttons --center --fixed

xterm -e "read -ep 'Press enter to select plymouth theme #9...' attends && sudo update-alternatives --config default.plymouth && sudo update-initramfs -u"

# ne pas terminer avec exit 0
