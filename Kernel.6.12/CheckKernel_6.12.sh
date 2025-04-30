#!/bin/bash

# 1) Vérifie si le kernel 6.12 LTS est enfin dans le kernel HWE d'Ubuntu
# 2) Vérifie la mise à jour du kernel 6.12 mainline

# Dépendances : ubuntu-mainline-kernel.sh, yad

# Lister les noyaux 6.12 disponibles
latest_612=$(ubuntu-mainline-kernel.sh -r 6.12 | sort -V | tail -n1 | sed 's/^v//')

# Récupérer la version actuelle du noyau installé
current_kernel=$(uname -r | grep -oP "^6\.12\.\d+")

# Vérification que les deux valeurs existent
if [[ -z "$latest_612" || -z "$current_kernel" ]]; then
    echo "Erreur : impossible de déterminer la version du noyau."
    exit 1
fi

# Kernel HWE
# Exécute la commande et filtre les résultats pour rechercher la version 6.12
if apt search linux-generic-hwe | grep -q "6.12"; then
    # Envoie une notification si 6.12 est trouvé
    CHOIX=$(yad --form --title="Kernel HWE" --window-icon=dialog-information --image=dialog-information --text="Le kernel 6.12 est disponible avec HWE\n\nInstaller HWE ?" --button="Oui:0" --button="Non:1" --width=500 --height=150 --fixed)
    # Tester la sortie
    if [ $? -eq 0 ]; then
        echo "Utilisateur a choisi : Oui"
        # Installer HME :
        # sudo apt install linux-generic-hwe-24.04
        
        xterm -fa 'Monospace' -fs 14 -geometry 150x24 -title "Installation HWE" -e '
        echo -e "\n>>> Installation HWE\n\nPressez la touche entrée pour démarrer."
        read
        clear        
        echo -e "\nVeuillez taper votre de passe.\n\nAttention, les caractères sont cachés.\n\n"
        sudo apt update
        sudo apt install linux-generic-hwe-24.04
        echo -e "\n****************************\nInstallation HWE terminée,\nquittez vos applis et pressez entrée pour redémarrer <<<"
        read
        reboot
        '        
        exit 0
    else
        echo "Utilisateur a choisi : Non"
    fi

else
    echo "6.12 toujours pas dans HWE"
    notify-send "6.12 HWE" "Kernel 6.12 HWE non dispo"
fi

# Kernel mainline
# Comparaison
if dpkg --compare-versions "$latest_612" gt "$current_kernel"; then
    CHOIX=$(yad --form --title="Kernel 6.12" --window-icon=dialog-information --image=dialog-information --text="Mise à jour dispo pour le kernel 6.12\n\nVersion actuelle   : $current_kernel\nNouvelle version : $latest_612\n\nInstaller la mise à jour ?" --button="Oui:0" --button="Non:1" --width=500 --height=150 --fixed)
        # Tester la sortie
    if [ $? -eq 0 ]; then
        echo "Utilisateur a choisi : Oui"
        pluma '/home/home/Documents/ScriptsLinux/Commandes update kernel mainline'
        exit 0
    else
        echo "Utilisateur a choisi : Non"
    fi
    
else
    echo "Pas de nouvelle version 6.12 mainline. (Actuel : $current_kernel / Dernier : $latest_612)"
    notify-send "Kernel mainline" "pas de mise à jour"
fi

exit 0

