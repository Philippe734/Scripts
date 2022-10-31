#!/bin/bash
# Mises à jour automatiques et silencieuses pour desktop et laptop
# Opération 1 : avertir l'utilisateur si fin de support Ubuntu
# Opération 2 : répare, nettoie et met à jour
# Philippe734 - 2019
# 1. Créer ce script avec sudo : sudo nano /opt/updates.sh
# 2. Copier-coller le contenu
# 3. Rendre exécutable le script : sudo chmod +x /opt/updates.sh
# 4. sudo visudo -f /etc/sudoers.d/custom
# 5. UserName ALL=NOPASSWD: /opt/updates.sh
# 6. Installer yad : sudo apt install yad -y
# 7. Exécuter avec > sudo < le script au démarrage d'Ubuntu

#
# >>> Partie 1 : alerte si fin de support LTS <<<
#
# Récupère la version majeure
laversion=$(lsb_release -rs)              # ex: 20.04
Major=$(echo $laversion | cut -d'.' -f 1) # ex: 20

# Convaincre l'utilisateur de mettre à niveau vers la dernière LTS tous les 2 ans
endsupport=$(($Major+2002))           # ex: 20+2002=2022
aujourdhui=$(date +%s)                # date en seconde
cond=$(date -d $endsupport-09-01 +%s) # date en seconde

if [ $aujourdhui -ge $cond ];then
    if [ "$DESKTOP_SESSION" == "mate" ];then
        variante="Ubuntu Mate"
    elif [ "$DESKTOP_SESSION" == "xubuntu" ];then
        variante="Xubuntu"
    else
        variante="Ubuntu"
    fi
    # Affiche la mise à niveau LTS à faire
    flagLTS="true"
fi


#
# >>> Partie 2 : mises à jour silencieues <<<
#
# /!\ Opérations systèmes d'Ubuntu à 5 min puis à 10 min, donc éviter ces créneaux.
# Définir une durée suffisante pour avoir assez de batterie
sleep 45m

# Récupère si machine sur secteur ou sur batterie
# BAT0 ok for Mate 16.04, 18.04 & 20.04
level=$(cat /sys/class/power_supply/BAT0/capacity)

# Récupère le niveau de batterie
status=$(cat /sys/class/power_supply/BAT0/status)

# Indicateur d'abandon
flag="true"

# Mises à jour si batterie forte ou sur secteur
if [ "${status}" != "Discharging" ]; then
 echo "machine sur secteur : OK"
 flag="true"
else
 if [ "${level}" -ge 86 ]; then
  flag="true"
  echo "machine sur batterie > 86% : OK"
 else
  flag="false"
  echo "batterie trop faible : abandon"
 fi
fi

# Test d'abandon
if [ "$flag" == "false" ]; then
 echo "abandon"
 exit 0
fi

MSG="Mise à jour en cours..."

doupdate () { (sudo apt update ; sudo apt full-upgrade -y ; sudo apt install -fy ; sudo apt autoclean ; sudo apt autoremove --purge -y) > /dev/null; quit ; }

doupdate | yad --notification --no-middle --text="$MSG" --image="system-software-update" --command="yad --center --title=Information --image=dialog-information --text=\"$MSG\" --text-align=left --fixed --button=OK" --listen

# sortir cette commande pour contourner un retour bloqué
sudo dpkg --configure -a

# Affiche la mise à niveau LTS
if [ "$flagLTS" == "true" ]; then
  update-manager -c & sleep 20s ; notify-send "Veuillez faire la MISE à NIVEAU" "branchez l'alimentation et prévoir 20 min." -t 30000
fi

exit 0
