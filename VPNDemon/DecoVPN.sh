#!/bin/bash
KillProgName="qbittorrent"
#notify-send "Fermeture des torrents..."
pkill $KillProgName
pkill $KillProgName
pkill $KillProgName
sleep 1
#notify-send "Déconnexion..."
pkill AutorecoVPN.sh
pkill AutoDeco3h.sh
sleep 1

# déconnexion du VPN torrent
nmcli con down uuid ... # UUI pour torrent

#nmcli con up ... # Ethernet

# connexion du VPN France
nmcli con up ... # UUI du VPN France

