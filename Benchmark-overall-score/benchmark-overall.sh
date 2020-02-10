#!/bin/bash
# Benchmark with sysbench and calculate a single overall score
# CPU, Memory & Disk IO
# 2020 - Philippe734

echo "Open your system monitor to watch."
echo "Please wait..."
echo "CPU..."
cpu=$(sysbench --test=cpu --cpu-max-prime=20000 --num-threads=32 run 2>/dev/null | grep "total number of events" | cut -f2 -d ":") 

echo "Disk IO..."
sysbench --test=fileio --file-total-size=2G prepare >/dev/null 2>&1

sleep 1s
io=$(sysbench --test=fileio --file-total-size=2G --file-test-mode=rndrw --max-time=180 --max-requests=0 run 2>/dev/null | grep "total number of events" | cut -f2 -d ":") 
sleep 1s

sysbench --test=fileio --file-total-size=2G cleanup >/dev/null 2>&1

echo "Memory..."
mem=$(sysbench --test=memory --num-threads=32 run 2>/dev/null | grep "total number of events" | cut -f2 -d ":")

echo "Done, overall score:"
echo "$((($cpu*$mem*3*$io*5)/(10**12)))"
