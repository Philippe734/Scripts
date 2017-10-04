#!/bin/bash

# Run this script at startup of the system
# This script allow you to run commands when you're right clicking on edge of screen
# 2016


MOUSE_ID=10 # device XID, run xinput without any option to get a list of devices and their IDs
interval=0.1 # sleep interval between tests in seconds
FLAG=0 # flag to ensure action commands
bNormal=1 # flag to ensure switch xinput set mapping

# screen resolution
Xaxis=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
Yaxis=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)

# edge areas
# to display the current mouse coordinates, run xdotool getmouselocation
# syntax: x_min x_max y_min y_max
e1=(0 $Xaxis 0 15) # top edge
e2=($Xaxis $Xaxis 0 $Yaxis) ; e2[0]=$(($Xaxis-15)) # right edge
e3=(0 $Xaxis 16 $Yaxis) ; e3[1]=$(($Xaxis-16)) # whole screen except others

# Function to disable mouse right button
function DisableB3 
{
	if [ $bNormal -eq 1 ] ; then  
		bNormal=0			
		xinput set-button-map $MOUSE_ID 1 2 0
	fi
}

# Function to enable mouse right button
function EnableB3 
{
	if [ $bNormal -eq 0 ] ; then
		bNormal=1
		FLAG=0
		xinput set-button-map $MOUSE_ID 1 2 3
	fi
}


while :; do

  eval $(xdotool getmouselocation --shell)

  if ( [ ${#e3[@]} -ne 0 ] && (( $X >= ${e3[0]} && $X <= ${e3[1]} && $Y >= ${e3[2]} && $Y <= ${e3[3]} )) ); then
	# your commands for edge area e3
	EnableB3
  fi

  if ( [ ${#e1[@]} -ne 0 ] && (( $X >= ${e1[0]} && $X <= ${e1[1]} && $Y >= ${e1[2]} && $Y <= ${e1[3]} )) ); then
	# your commands for edge area e1  
	DisableB3
	BT=$(xinput --query-state $MOUSE_ID | grep 'button\[3\]=down' | cut -d'=' -f 2 )
	if [ "$BT" = "down" ] && [ $FLAG -eq 0 ] ; then
		echo "### run commands for top edge ###"			
		BT=""; FLAG=1; sleep 0.5
	fi
  fi

  if ( [ ${#e2[@]} -ne 0 ] && (( $X >= ${e2[0]} && $X <= ${e2[1]} && $Y >= ${e2[2]} && $Y <= ${e2[3]} )) ); then
	# your commands for edge area e2
	DisableB3
	BT=$(xinput --query-state $MOUSE_ID | grep 'button\[3\]=down' | cut -d'=' -f 2 )
	if [ "$BT" = "down" ] && [ $FLAG -eq 0 ] ; then
		echo "### run commands for right edge ###"	
		xdotool key alt+F4		
		BT=""; FLAG=1; sleep 0.5
	fi
  fi

  sleep $interval

done

exit 0

