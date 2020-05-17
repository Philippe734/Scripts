#!/bin/bash
# GUI for Ventoy Multiboot USB - https://www.ventoy.net
# To prevent prompt for password sudo, use sudoers
# Need yad = sudo apt install yad
# version 1.0

_ventoyscript="/path/to/Ventoy2Disk.sh"

# list usb devices, copyright lemsx1 from superuser
REMOVABLE_DRIVES=""
for _device in /sys/block/*/device; do
    if echo $(readlink -f "$_device")|egrep -q "usb"; then
        _disk=$(echo "$_device" | cut -f4 -d/)
		_info=$(lsblk -rno NAME,SIZE,MOUNTPOINT,LABEL /dev/"$_disk")
        REMOVABLE_DRIVES="$_info!$REMOVABLE_DRIVES"
    fi
done

_out=$(yad --center --image="drive-removable-media-usb-pendrive" --window-icon="drive-removable-media-usb-pendrive" --title="Multiboot USB with ventoy" --form --field="Device ":CB "$REMOVABLE_DRIVES" --field="Set a name ":CBE --width=500 --height=100 --fixed)

_drive=$(echo "$_out" | cut -f 1-1 -d ' ' | head -1)
_media=$(echo $_out | cut -f1 -d'|')
_name=$(echo $_out | cut -f2 -d'|')

echo "_out=$_out"
echo "_drive=$_drive"
echo "_media=$_media"
echo "_name=$_name"

if [ -z "$_media" -o "$_media" == "||" ]; then
    echo "canceled"
    exit 0
fi

yad --center  --image="dialog-warning" --window-icon="drive-removable-media-usb-pendrive" --title="Attention" --button=No:0 --button=Yes:1 --text="Are you sure to erase this device?\n$_media" --fixed --width=300 --height=70

if [ $? = 1 ]; then
    xterm -e "sudo $_ventoyscript -I /dev/$_drive"    
    # Rename the first partition
    sudo exfatlabel /dev/"$_drive"1 "$_name"
    sleep 1
	notify-send "Done" "Ready to receive iso" -i "drive-removable-media-usb-pendrive"
else
    echo "canceled"
fi

exit 0

