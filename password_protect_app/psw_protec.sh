#!/bin/bash

# Simple password protection for application
# 2023 - Philippe734
# Prompt for password then run application
#
# Require yad:
# $ sudo apt install yad
#
# Before use it, hide the application's file in your system, then use these commands to get the full path of your application, encrypted and coded in base64, with your password:
# $ password=$(yad --text-align=center --text="Password" --entry --entry-text="" --hide-text --fixed --title="" --button=OK)
# $ data="/Path/To/Your/Frame.AppImage"
# $ echo "$data" | openssl enc -aes256 -a -pbkdf2 -pass pass:"$password"

function main
{
password=$(yad --title="Application's name" --height=150 --width=400 --hide-text --fixed --text="<span foreground='blue'><b><big><big>Please enter your password</big></big></b></span>" --entry --entry-text="" --text-align=center --center --borders=20 --image='/home/username/Pictures/application's icon.png')

data="xxx" # replace xxx with the full path of your application, encrypted and coded in base64

MyApp=$(echo "$data" | openssl enc -aes256 -d -a -pbkdf2 -pass pass:"$password")
$password=""

# test if file exist
if [ -a $MyApp ]
then
    $MyApp # run your application
    exit 0
else
    notify-send "Wrong password" "Try $x/3"
fi
}

# limit try
x=1
while [ $x -le 3 ]
do
  main
  x=$(( $x + 1 ))
done

exit 0

