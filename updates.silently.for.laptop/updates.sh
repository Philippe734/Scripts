#!/bin/bash
# Mises à jour automatiques et silencieuses pour desktop et laptop
# Opérations : répare, nettoie et met à jour
# Philippe734 - 2019
# Lien vers ce script : https://bit.ly/2sY7MiX
# 1. Créer ce script avec sudo : sudo nano /opt/updates.sh
# 2. Copier-coller le contenu
# 3. Rendre exécutable le script : sudo chmod +x /opt/updates.sh
# 4. sudo visudo -f /etc/sudoers.d/custom
# 5. UserName ALL=NOPASSWD: /opt/updates.sh
# 6. Installer yad : sudo apt install yad -y
# 7. Exécuter avec > sudo < le script au démarrage d'Ubuntu
 
# /!\ Opérations systèmes à 5 min puis à 10 min
# Définir une durée suffisante pour avoir assez de batterie
sleep 8m
 
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
 
MSG="Mises à jour en cours, n'éteignez pas l'ordinateur..."
 
doupdate () { (sudo apt update ; sudo apt full-upgrade -y ; sudo apt-get install -fy ; sudo apt-get autoclean ; sudo apt-get autoremove --purge -y) > /dev/null; quit ; }
 
doupdate | yad --notification --no-middle --text="$MSG" --image="system-software-update" --command="yad --center --title=Information --image=dialog-information --text=\"$MSG\" --text-align=left --fixed --button=OK" --listen
 
# sortir cette commande pour contourner un retour bloqué
sudo dpkg --configure -a
 
exit 0
