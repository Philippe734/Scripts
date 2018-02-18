#!/bin/bash

killProgramName="qbittorrent"
killProgramNameB="firefox"
interface="org.freedesktop.NetworkManager.VPN.Connection"
member="VpnStateChanged"
logPath="/tmp/vpndemon"
header="VPNDemon\nProtection contre déconnexion VPN\n\n"

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
    killProgramName=$(zenity --entry --title="VPNDemon" --text="$header Enter name of process to kill when VPN disconnects:")
fi

result=$?
if [ $result = 0 ]
then
    if [ $killProgramName ]
    then
        header="$header Cibles : $killProgramName + $killProgramNameB\n\n"

        (tail -f "$logPath") |
        {
            zenity --progress --title="VPNDemon" --text="$header Surveillance du VPN"

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
                        echo "# $header VPN Connecté $currentDate" >> "$logPath"
                    fi

                    # Check if this a VPN disconnected (uint32 7) event.
                    if [ x"$(echo "$line" | grep 'uint32 6\|uint32 7')" != x ]
                    then
                        echo "VPN Disconnected $currentDate"
						notify-send "Déconnexion du VPN" "Reconnexion en cours..."
                        echo "# $header VPN Déconnecté $currentDate" >> "$logPath"

                        # Kill target process.
						pkill $killProgramName
						pkill $killProgramName
						pkill $killProgramName
						pkill $killProgramNameB
						pkill $killProgramNameB
						pkill $killProgramNameB
                    fi
                done)
            }
        }
    else
        zenity --error --text="No process name entered."
    fi
fi
echo "Déconnecter VPN"
exec /ThePathTo/DecoVPN.sh &

