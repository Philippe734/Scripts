#!/usr/bin/env bash

# Notifies the user if the battery is low.
# Executes some command (like hibernate) on critical battery.
# This script is supposed to be called from a cron job.
# If you change this script's name/path, don't forget to update it in crontab !!

level=$(cat /sys/class/power_supply/BAT1/capacity)
status=$(cat /sys/class/power_supply/BAT1/status)

# Exit if not discharging
if [ "${status}" != "Discharging" ]; then
  exit 0
fi


# Source the environment variables required for notify-send to work.
. /home/anmol/.env_vars

# Percentage at which to show low-battery notification
low_notif_percentage=20
# Percentage at which to show critical-battery notification
critical_notif_percentage=15
# Percentage at which to power-off
critical_action_percentage=10


if [ "${level}" -le ${critical_action_percentage} ]; then
  # sudo is required when running from cron
  sudo systemctl hibernate
  exit 0
fi

if [ "${level}" -le ${critical_notif_percentage} ]; then
  notify-send -i '/usr/share/icons/gnome/256x256/status/battery-caution.png' "Battery critical: ${level}%"
  exit 0
fi

if [ "${level}" -le ${low_notif_percentage} ]; then
  notify-send -i '/usr/share/icons/gnome/256x256/status/battery-low.png' "Battery low: $level%"
  exit 0
fi
