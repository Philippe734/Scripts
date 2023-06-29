#!/bin/bash

# Simple password protection for application
# 2023 - Philippe734
# It ask password then run application
#
# Require yad:
# $ sudo apt install yad
#
# Before use it, use these command to get the full path of your application, encrypted and coded in base64, with your password:
# $ echo -n "/Path/To/Your/Application" | openssl enc -aes256 -a -pbkdf2

function main
{
password=$(yad --text-align=center --text="Password" --entry --entry-text="" --hide-text --fixed --title="" --button=OK)

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

