#!/bin/bash
KillProgName="qbittorrent"
notify-send "Fermeture des torrents..."
pkill $KillProgName
pkill $KillProgName
pkill $KillProgName
sleep 2
notify-send "Déconnexion..."
pkill AutorecoVPN.sh
sleep 2
nmcli con down uuid xxx-xx-xx-xx-xxxxx <<<<<<<<<<< remplacer xxx par UUID du VPN
notify-send "VPN déconnecté"
