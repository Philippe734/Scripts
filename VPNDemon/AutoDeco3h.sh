#!/bin/bash
# déco périodique
while [ "true" ]
do
	sleep 4h
    echo "Déconnexion volontaire du VPN pour éviter les connexions mortes"
    nmcli con down uuid ... # UUI pour torrent
done

exit 0

