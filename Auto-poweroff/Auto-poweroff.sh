#!/bin/bash

# Notifies the user if the battery is low then poweroff when critical.
# Tested succesfull on Ubuntu Gnome 16.04 x64 with ASUS computer.
# This script is supposed to be called from a cron job.
# If you change this script's name/path, don't forget to update it in crontab.
# Credit to Anmol-Singh-Jaggi on GitHub

# Required for notify-send to work
eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)";

# BAT0 with Ubuntu 16.04
level=$(cat /sys/class/power_supply/BAT0/capacity)
status=$(cat /sys/class/power_supply/BAT0/status)

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
  # Sudo is required in cron
  sudo systemctl poweroff
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