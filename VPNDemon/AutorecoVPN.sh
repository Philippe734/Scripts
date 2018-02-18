#!/bin/bash
# étape 1 : récupérer le uui du vpn : nmcli con
# étape 2 : saisir le uui dans ce script
# étape 3 : saisir son nom dans ce script
TargetProgramName="qbittorrent"
notify-send "Connexion du VPN..."
exec /ThePathTo/vpndemon.sh &
while [ "true" ]
do
	VPNCON=$(nmcli con status)
	if [[ $VPNCON != *openvpn3* ]]; then
		echo "VPN déconnecté"
		(sleep 1s && nmcli con up uuid xxxx-xx-xx-xx-xxxxx)
		FLAGRECO="vrai"
	else
		if [[ $FLAGRECO = "vrai" ]]; then
			FLAGRECO="faux"
			exec $TargetProgramName &
		fi
	fi
	sleep 10
done
