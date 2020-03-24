#!/bin/bash
# GUI tool to format USB device with YAD (sudo apt install yad)
# Run this script with pkexec : https://askubuntu.com/a/332847
# 1. Select the device
# 2. Select the filesystem
# 3. Set a name
# no copyright @ 2018

# list usb devices, copyright lemsx1 from superuser:
REMOVABLE_DRIVES=""
for _device in /sys/block/*/device; do
    if echo $(readlink -f "$_device")|egrep -q "usb"; then
        _disk=$(echo "$_device" | cut -f4 -d/)
		_info=$(lsblk -rno NAME,SIZE,MOUNTPOINT,LABEL /dev/"$_disk"1)
        REMOVABLE_DRIVES="$_info!$REMOVABLE_DRIVES"
    fi
done

_out=$(yad --center --title="Format USB device" --form --field="Device ":CB "$REMOVABLE_DRIVES" --field="Filesystem ":CB 'FAT32!NTFS!EXT4' --field="Name ":CBE --width=500 --height=100 --fixed)

_drive=$(echo "$_out" | cut -f1 -d' ')
_media=$(echo $_out | cut -f1 -d'|')
_filesystem=$(echo $_out | cut -f2 -d'|')
_name=$(echo $_out | cut -f3 -d'|')

#echo "drive : $_drive"
#echo "_media : $_media"
#echo "_filesystem : $_filesystem"
#echo "_name : $_name"


if [ -z "$_media" -o "$_media" == "||" ]; then
    echo "canceled"
    exit 0
fi

yad --center  --image "dialog-question" --title "Attention" --button=No:0 --button=Yes:1 --text "Are you sure to format this device?\n$_media" --fixed --width=300 --height=70

if [ $? = 1 ]; then
    umount /dev/"$_drive"
    case $_filesystem in
        "FAT32") _filesystem="mkdosfs -F32 -I -n";;
        "NTFS") _filesystem="mkfs.ntfs -f -L";;
        "EXT4") _filesystem="mkfs.ext4 -L";;
    esac
    #echo "filesystem : $_filesystem"
    #echo "drive : $_drive"
    #echo "COMMAND : $_filesystem $_name /dev/$_drive"
	$_filesystem "$_name" /dev/"$_drive" | yad --progress --pulsate --text="Please wait while formating..." --auto-close --width=300 --height=70 --fixed --undecorated --center --no-buttons --progress-text=""
	echo "formated"
else
    echo "canceled"
fi

exit 0
