#!/bin/bash
# Mises à jour automatiques et silencieuses pour desktop et laptop
# Opération 1 : avertir l'utilisateur si fin de support Ubuntu
# Opération 2 : répare, nettoie et met à jour
# Philippe734 - 2019
# Lien vers la version dynamiquement mise à jour de ce script : https://bit.ly/2sY7MiX
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
laversion=$(lsb_release -rs)
Major=$(echo $laversion | cut -d'.' -f 1)

# Ajoute 3 ans à la version pour savoir si périmé (durée support de LTS Mate/Xubuntu/Lubuntu)
endsupport=$(($Major+2003))
aujourdhui=$(date +%s)
cond=$(date -d $endsupport-03-01 +%s)

if [ $aujourdhui -ge $cond ];
then
	# Informe l'uilisateur qu'Ubuntu est obsolète
	yad --center --title=Information --image=dialog-information --text-align=left --fixed --button=OK --text="Attention\n\nVotre système Linux Ubuntu Mate (ou Xubuntu) $laversion est obsolète et périmé.\n\nIl n'y a plus de mises à jour de sécurité et vos applications ne seront plus mises à jour.\n\nVeuillez contacter votre responsable informatique, ou un geek, pour mettre à niveau vers la dernière version LTS d'Ubuntu Mate (ou Xubuntu)."
fi


#
# >>> Partie 2 : mises à jour silencieues <<<
#
# /!\ Opérations systèmes d'Ubuntu à 5 min puis à 10 min, donc éviter ces créneaux.
# Définir une durée suffisante pour avoir assez de batterie
sleep 9m

# Récupère si machine sur secteur ou sur batterie
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
 if [ "${level}" -ge 80 ]; then
  flag="true"
  echo "machine sur batterie > 80% : OK"
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

MSG="Mises à jour en cours..."

doupdate () { (sudo apt update ; sudo apt full-upgrade -y ; sudo apt install -fy ; sudo apt autoclean ; sudo apt autoremove --purge -y) > /dev/null; quit ; }

doupdate | yad --notification --no-middle --text="$MSG" --image="system-software-update" --command="yad --center --title=Information --image=dialog-information --text=\"$MSG\" --text-align=left --fixed --button=OK" --listen

# sortir cette commande pour contourner un retour bloqué
sudo dpkg --configure -a

exit 0
