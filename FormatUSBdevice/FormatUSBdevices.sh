#!/bin/bash
# GUI tool to format USB device with YAD (sudo apt install yad)
# Run this script with sudo
# 1. Select the device
# 2. Select the filesystem
# 3. Set a name
# no copyright @ 2018

# list usb devices, copyright lemsx1 from superuser:
REMOVABLE_DRIVES=""
for _device in /sys/block/*/device; do
    if echo $(readlink -f "$_device")|egrep -q "usb"; then
        _disk=$(echo "$_device" | cut -f4 -d/)
		_info=$(lsblk -rno NAME,SIZE,MOUNTPOINT /dev/"$_disk"1)
        REMOVABLE_DRIVES="$_info!$REMOVABLE_DRIVES"
    fi
done

_out=$(yad --center --title="Format" --form --field="Device to format":CB "$REMOVABLE_DRIVES" --field="Filesystem":CB 'FAT32!NTFS!EXT4' --field="Name to set":CBE )

_drive=$(echo "$_out" | cut -f1 -d' ')
_media=$(echo $_out | cut -f1 -d'|')
_filesystem=$(echo $_out | cut -f2 -d'|')
_name=$(echo $_out | cut -f3 -d'|')

if [ -z "$_media" -o "$_media" == "||" ]; then
    echo "canceled"
    exit 0
fi

yad --center  --image "dialog-question" --title "Attention" --button=No:0 --button=Yes:1 --text "Are you sure to format this device?\n$_media"

if [ $? = 1 ]; then
    sudo umount /dev/"$_drive"
    case $_filesystem in
        "FAT32") _filesystem="mkdosfs -F32 -I -n";;
        "NTFS") _filesystem="mkfs.ntfs -f -L";;
        "EXT4") _filesystem="mkfs.ext4 -L";;
    esac
	sudo $_filesystem "$_name" /dev/"$_drive" | zenity --progress --pulsate --title="Processing..." --auto-close --no-cancel
	echo "formated"
else
    echo "canceled"
fi

exit 0

