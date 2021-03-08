#!/bin/bash
if [[ $(last -p now -s -{{ sessionDuration + 1 }}min -t -{{ sessionDuration }}min | grep "guest-") ]]; then
    echo "Restart lightdm"
    sudo service lightdm stop
    sleep {{ timeBetween2Session }}s; 
    sudo service lightdm start
else
    echo "No session to kill"
fi