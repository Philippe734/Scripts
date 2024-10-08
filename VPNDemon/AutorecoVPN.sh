#!/bin/bash
# étape 1 : récupérer le UUI du vpn : nmcli con
# étape 2 : saisir le UUI dans ce script, DecoVPN.sh

echo $$ > /home/username/Documents/Scripts/VPN/mainPID

TargetProgramName="qbittorrent"

VPNUUID="..." # UUI pour torrent
VPNFRANCE="..." # UUI VPN France

# Déconnexion du VPN France
nmcli con down uuid "$VPNFRANCE" # UUI VPN France
sleep 500ms

# Activer le monitoring
exec /home/username/Documents/Scripts/VPN/vpndemon.sh &

while [ "true" ]
do
	VPNCON=$(nmcli con show --active | grep "$VPNUUID")
	if [ -z "$VPNCON" ]; then
		echo "VPN déconnecté"
		(sleep 1s && nmcli con up uuid "$VPNUUID") 
  		notify-send $(nmcli -g name,type con show --active | grep vpn)		
		FLAGRECO="vrai"
	else
		if [[ $FLAGRECO = "vrai" ]]; then
			FLAGRECO="faux"
			exec $TargetProgramName &
		fi
	fi
	sleep 3
done
