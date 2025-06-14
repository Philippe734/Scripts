#!/bin/bash

# Remove the animation intro of Steam Big Picture on Linux

# create empty video
ffmpeg -f lavfi -i color=c=black:s=1280x720:d=0.1 -an bigpicture_startup.webm

# replace it
mv bigpicture_startup.webm ~/.local/share/Steam/steamui/movies/bigpicture_startup.webm

# set permissions
chmod 444 ~/.local/share/Steam/steamui/movies/bigpicture_startup.webm

