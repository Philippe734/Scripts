#!/bin/bash

# password protection for application
# ask your password then run your application
# require: yad
# sudo apt install yad
#
# before to use the script, use these commands to get your password in hexadecimal
# and get the full path of your application, coded in base64

function main
{
password=$(yad --text-align=center --text="Mot de passe" --entry --entry-text="" --hide-text --fixed --title="" --button=OK)

b=$(echo -n "$password" | od -A n -t x1 | sed 's/ *//g')

if [[ "$b" == 0123abcde ]] # replace it with your password in hexadecimal
then
    f=$(echo -n 'nkmlfu156g4sf8d6' | base64 --decode) # replace it with the full path of your application, coded in base64
    $f # run your application
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

