#!/usr/bin/env bash

# Notifies the user if the battery is low.
# Executes some command (like hibernate) on critical battery.
# This script is supposed to be called from a cron job.
# If you change this script's name/path, don't forget to update it in crontab !!

# Required for notify-send to work
eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)";

level=$(cat /sys/class/power_supply/BAT1/capacity)
status=$(cat /sys/class/power_supply/BAT1/status)

# Exit if not discharging
if [ "${status}" != "Discharging" ]; then
  exit 0
fi


# Percentage at which to show low-battery notification
low_notif_percentage=14
# Percentage at which to show critical-battery notification
critical_notif_percentage=11
# Percentage at which to power-off
action_percentage=8


if [ "${level}" -le ${action_percentage} ]; then  
  notify-send "Warning, Linux will be poweroff because battery is too low: ${level}%" -t 15
  sleep 5
  systemctl poweroff
  exit 0
fi

if [ "${level}" -le ${critical_notif_percentage} ]; then
  notify-send "Battery critical: ${level}%" -t 15
  exit 0
fi

if [ "${level}" -le ${low_notif_percentage} ]; then
  notify-send "Battery low: $level%" -t 15
  exit 0
fi
