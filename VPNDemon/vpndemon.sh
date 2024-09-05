#!/bin/bash

killProgramName="qbittorrent"
killProgramNameB="firefox"
interface="org.freedesktop.NetworkManager.VPN.Connection"
member="VpnStateChanged"
logPath="/tmp/vpndemon"
header="VPN\n"

# Clear log file.
> "$logPath"

list_descendants()
{
    local children=$(ps -o pid= --ppid "$1")

    for pid in $children
    do
        list_descendants "$pid"
    done

    echo "$children"
}

# Consider the first argument as the target process
if [ -z "$killProgramName" ]
then
    killProgramName=$(zenity --entry --title="VPN" --text="$header Enter name of process to kill when VPN disconnects:")
fi

result=$?
if [ $result = 0 ]
then
    if [ $killProgramName ]
    then
        header="$killProgramName ; $killProgramNameB ; wine"

        (tail -f "$logPath") |
        {
            yad --progress --title="VPN" --text="$header" --progress-text="" --fixed --geometry +0+9999 --button="Déconnecter" --window-icon='/home/home/Documents/ScriptsLinux/VPN/icon wall-bricks-512.png'

            # Kill all child processes upon exit.
            kill $(list_descendants $$)
        } |
        {
            # Monitor for VPNStateChanged event.
            dbus-monitor --system "type='signal',interface='$interface',member='$member'" |
            {
                # Read output from dbus.
                (while read -r line
                do
                    currentDate=`date +'%m-%d-%Y %r'`

                    # Check if this a VPN connection (uint32 2) event.
                    if [ x"$(echo "$line" | grep 'uint32 3')" != x ]
                    then
                        echo "VPN Connected $currentDate"
                        echo "# Connecté $currentDate" >> "$logPath"
                    fi

                    # Check if this a VPN disconnected (uint32 7) event.
                    if [ x"$(echo "$line" | grep 'uint32 6\|uint32 7')" != x ]
                    then
                        echo "VPN Disconnected $currentDate"
						notify-send "Déconnexion du VPN" "Reconnexion en cours..."
                        echo "# Déconnecté $currentDate" >> "$logPath"

                        # Kill target process.
						pkill $killProgramName
						pkill $killProgramName
						pkill $killProgramName
						pkill $killProgramNameB
						pkill $killProgramNameB
						pkill $killProgramNameB
						wineserver -k
                    fi
                done)
            }
        }
    else
        zenity --error --text="No process name entered."
    fi
fi
echo "Déconnecter VPN"
exec /home/username/Documents/Scripts/VPN/DecoVPN.sh &
