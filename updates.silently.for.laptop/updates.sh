#!/bin/bash

# Run updates automatically and silently on machine running on battery, perfect for laptop.
# Also repair and clean packages.
#
# Yad is required: sudo apt install yad
# Allow this script to be execute without prompt password with this :
#        sudo visudo -f /etc/sudoers.d/custom
#        UserName ALL=NOPASSWD: /path to this/script.sh
#
# Tested succesfull on Ubuntu 14.04, 16.04 and 18.04
# This script is supposed to be start at login and run with sudo
# Philippe734 - 2017

# Begin of the script

# Run updates on battery if > 80% at login
sleep 1m

level=$(cat /sys/class/power_supply/BAT0/capacity)
status=$(cat /sys/class/power_supply/BAT0/status)

# Exit if not discharging
if [ "${status}" != "Discharging" ]; then
  exit 0
fi

# Update
if [ "${level}" -ge 80 ]; then
	MSG="Updates in progress..."
	notify-send "$MSG" -t 2000
	doupdate () { (sudo apt update ; sudo dpkg --configure -a ; sudo apt-get install -fy ; sudo apt-get autoclean ; sudo apt-get autoremove --purge -y ; sudo apt full-upgrade -y) > /dev/null; quit ; }
	doupdate | yad --notification --no-middle --text="$MSG" --image="system-software-update" --command="yad --center --image=dialog-information --text=\"$MSG\" --button=OK" --listen
fi

exit 0
