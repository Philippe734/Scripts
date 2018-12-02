#!/bin/bash
# Notifies the user if the battery is low then supsend when critical.
# Usefull script when Ubuntu fail to suspend the laptop.
# You can replace suspend with shutdown or hiberbate.
# This script is supposed to be start at login using "Startup Applications Preferences"
# Infinite loop which check battery level every minute

while [ "true" ]
do
	sleep 1m
    # BAT0 with Ubuntu 16.04+
    level=$(cat /sys/class/power_supply/BAT0/capacity)
    status=$(cat /sys/class/power_supply/BAT0/status)

    # If discharging
    if [ "${status}" = "Discharging" ]; then
    
        # Percentage at which to show critical-battery notification
        critical_notif_percentage=10

        # Percentage at which to suspend
        action_percentage=6

        if [ "${level}" -le ${action_percentage} ]; then  
          notify-send "Standby in 5 seconds, battery too low"
          sleep 5
          systemctl suspend
        elif [ "${level}" -le ${critical_notif_percentage} ]; then
          notify-send "Low battery"
        fi
    fi
done
exit 0
