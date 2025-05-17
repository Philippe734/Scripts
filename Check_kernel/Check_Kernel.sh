#!/bin/bash

# 1) Vérifie si le kernel 6.14 stable est enfin dans le kernel HWE d'Ubuntu
# 2) Vérifie la mise à jour du kernel 6.14 mainline

# Dépendances : ubuntu-mainline-kernel.sh, yad

# Kernel HWE
# Exécute la commande et filtre les résultats pour rechercher la version 6.12
if apt search linux-generic-hwe | grep -E '6\.12|6\.13|6\.14' ; then
    # Envoie une notification si kernel autre que 6.11
    CHOIX=$(yad --form --title="Kernel HWE" --window-icon=dialog-information --image=dialog-information --text="Nouveau kernel disponible avec HWE\n\nInstaller HWE ?" --button="Oui:0" --button="Non:1" --width=500 --height=150 --fixed)
    # Tester la sortie
    if [ $? -eq 0 ]; then
        echo "Utilisateur a choisi : Oui"
        # Installer HME :
        # sudo apt install linux-generic-hwe-24.04
        
        xterm -fa 'Monospace' -fs 14 -geometry 150x24 -title "Installation HWE" -e '
        echo -e "\n>>> Installation HWE\n\nOK pour démarrer ?"
        read
        clear        
        echo -e "apt search linux-generic-hwe..."
        apt search linux-generic-hwe
        echo -e "\nsudo apt update..."
        sudo apt update
        echo -e "\nsudo apt install linux-generic-hwe-24.04..."
        sudo apt install linux-generic-hwe-24.04
        echo -e "\n-------------------\nInstallation HWE terminée, tapez entrée pour redémarrer <<<"
        read
        reboot
        '        
        exit 0
    else
        echo "Utilisateur a choisi : Non"
    fi

else
    echo "6.14 toujours pas dans HWE"
fi

# Kernel mainline
# Lister les noyaux 6.14 disponibles
latest_614=$(ubuntu-mainline-kernel.sh -r 6.14 | grep -o 'v6\.14\.[0-9]\+' | sed 's/v//' | sort -V | tail -n1)

# Récupérer la version actuelle du noyau installé
current_kernel=$(uname -r | grep -oP "^6\.14\.\d+")

# Vérification que les deux valeurs existent
if [[ -z "$latest_614" || -z "$current_kernel" ]]; then
    echo "Erreur : impossible de déterminer la version du noyau."
    exit 1
fi

# Comparaison
if dpkg --compare-versions "$latest_614" gt "$current_kernel"; then
    CHOIX=$(yad --form --title="Kernel 6.14" --window-icon=dialog-information --image=dialog-information --text="Mise à jour dispo pour le kernel 6.14\n\nVersion actuelle   : $current_kernel\nNouvelle version : $latest_614\n\nInstaller la mise à jour ?" --button="Oui:0" --button="Non:1" --width=500 --height=150 --fixed)
        # Tester la sortie
    if [ $? -eq 0 ]; then
        echo "Utilisateur a choisi : Oui"
        xterm -fa 'Monospace' -fs 14 -geometry 150x24 -title "Installation Kernel mainline" -e 'bash "/home/home/Documents/ScriptsLinux/Commandes update kernel mainline"'
        exit 0
    else
        echo "Utilisateur a choisi : Non"
    fi
    
else
    echo "Pas de nouvelle version 6.14 mainline. (Actuel : $current_kernel / Dernier : $latest_614)"
    # notify-send "Kernel mainline" "pas de mise à jour"
fi

exit 0

