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
if [ $aujourdhui -ge $cond ];
then
	# alert the user
	zenity --warning --text="Warning\n\nYour Ubuntu $laversion is at end of support.\n\nNo more security updates\nNo more updates for your softwares\n\nPlease, contact your IT support\nin order to get the latest Ubuntu LTS."
else
	echo "custom script : version Ubuntu still support"
fi  

exit 0


