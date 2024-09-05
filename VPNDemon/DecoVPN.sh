#!/bin/bash

exec /home/user/Documents/Scripts/KillBackgroundApps.sh &

KillProgName="qbittorrent"
#notify-send "Fermeture des torrents..."
pkill $KillProgName
pkill $KillProgName
pkill $KillProgName
sleep 1
#notify-send "Déconnexion..."
PID=$(cat /home/user/Documents/Scripts/VPN/mainPID)
kill $PID
sleep 1

# connexion du VPN France
nmcli con up ... # UUI du VPN France

# déconnexion du VPN torrent
nmcli con down uuid ... # UUI pour torrent

#nmcli con up ... # Ethernet

notify-send $(nmcli -g name,type con show --active | grep vpn)
