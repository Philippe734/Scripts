#!/bin/bash
# List applications installed by user

apt-mark showmanual > ~/manual-installed.txt
initial=( $(zgrep -oP "(?<=Package: ).*" /var/log/installer/initial-status.gz) )
for p in ${initial[@]} ; do sed -i "/^$p$/d" ~/manual-installed.txt ; done
cat ~/manual-installed.txt
exit 0
