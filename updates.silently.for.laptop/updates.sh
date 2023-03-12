#!/bin/bash
# Automatically updates silently
# Operation 1 : alert user if end Ubuntu's support
# Operation 2 : update, repair, clean
# Philippe734 - 2019
# 1. Create this script with sudo: sudo nano /opt/updates.sh
# 2. Copy past inside
# 3. Allow to be executed: sudo chmod +x /opt/updates.sh
# 4. sudo visudo -f /etc/sudoers.d/custom
# 5. UserName ALL=NOPASSWD: /opt/updates.sh
# 6. Install yad: sudo apt install yad -y
# 7. Start with sudo in start apps of Ubuntu

#
# >>> Part 1 : end of support LTS <<<
#
# Get major release
laversion=$(lsb_release -rs)              # ex: 20.04
Major=$(echo $laversion | cut -d'.' -f 1) # ex: 20

# Force user to do the upgrade to the last LTS each 2 years
endsupport=$(($Major+2002))           # ex: 20+2002=2022
aujourdhui=$(date +%s)                # date second
cond=$(date -d $endsupport-09-01 +%s) # date second

if [ $aujourdhui -ge $cond ];then
    if [ "$DESKTOP_SESSION" == "mate" ];then
        variante="Ubuntu Mate"
    elif [ "$DESKTOP_SESSION" == "xubuntu" ];then
        variante="Xubuntu"
    else
        variante="Ubuntu"
    fi
    # Affiche la mise à niveau LTS à faire
    flagLTS="true"
fi


#
# >>> Part 2 : silently update <<<
#
sleep 15m

notify-send "Update" "in progress..."

# Get state battery
# BAT0 ok for Mate 16.04, 18.04, 20.04, 22.04
level=$(cat /sys/class/power_supply/BAT0/capacity)

# Get battery status
status=$(cat /sys/class/power_supply/BAT0/status)

# Give up flag
flag="true"

# Update if AC or enough battery
if [ "${status}" != "Discharging" ]; then
 echo "AC : OK"
 flag="true"
else
 if [ "${level}" -ge 86 ]; then
  flag="true"
  echo "battery > 86% : OK"
 else
  flag="false"
  echo "battery too low : giveup"
 fi
fi

# test giveup
if [ "$flag" == "false" ]; then
 echo "giveup"
 exit 0
fi

MSG="Update in progress..."

doupdate () { (sudo apt update ; sudo apt full-upgrade -y ; sudo apt install -fy ; sudo apt autoclean ; sudo apt autoremove --purge -y) > /dev/null; quit ; }

doupdate | yad --notification --no-middle --text="$MSG" --image="system-software-update" --command="yad --center --title=Information --image=dialog-information --text=\"$MSG\" --text-align=left --fixed --button=OK" --listen

# exit this command to avoid block
sudo dpkg --configure -a

notify-send "Done" "updates OK"

# Show the update to the last LTS
if [ "$flagLTS" == "true" ]; then
  update-manager -c & sleep 20s ; notify-send "Do the upgrade" "connect the power supply and allow 60 min." -t 30000
fi

exit 0
