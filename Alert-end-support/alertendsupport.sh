#!/bin/bash

# Alert the user when the system is at end of support
# Good for LTS version
# sudo nano /opt/script/alertendsupport.sh
# Move it in /opt/scripts/
# Run it at startup

# Get the Major version of Ubuntu
laversion=$(cat /etc/lsb-release | grep 'DISTRIB_RELEASE=' | cut -d'=' -f 2)
Major=$(cat /etc/lsb-release | grep 'DISTRIB_RELEASE=' | cut -d'=' -f 2 | cut -d'.' -f 1)

# Add 2000 + 5 years for LTS version
endsupport=$(($Major+2005))
aujourdhui=$(date +%s)
cond=$(date -d $endsupport-03-01 +%s)

# compare today with the date of end of support
if [ $aujourdhui -ge $cond ];then
    if [ "$DESKTOP_SESSION" == "mate" ];then
        variante="Ubuntu Mate"
    elif [ "$DESKTOP_SESSION" == "xubuntu" ];then
        variante="Xubuntu"
    else
        variante="Ubuntu"
    fi
	# Alert the user
	yad --center --title=Information --image=dialog-information --text-align=left --fixed --button=OK --text="Warning\n\nYour Ubuntu $laversion is at end of support.\n\nNo more security updates\nNo more updates for your softwares\n\nPlease, contact your IT support\nin order to get the latest Ubuntu LTS."
fi

exit 0
