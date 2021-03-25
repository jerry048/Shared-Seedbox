#!/bin/bash
clear
## Grab interface name
 read -p "Enter interface name (e.g. eno1): " interface

## Define Monitor_Network_Bandwidth
function Monitor_Network_Bandwidth {
	rx=$(sar -n DEV 1 1 | grep $interface | grep Average | awk '{print $5}')
	rx=$(echo ${rx%.*})
	rx=$(expr $rx \* 125 / 131072)

	tx=$(sar -n DEV 1 1 | grep $interface | grep Average | awk '{print $6}')
	tx=$(echo ${tx%.*})
	tx=$(expr $tx \* 125 / 131072)
}

while true; do
	tput cup 0 0
	Monitor_Network_Bandwidth
	echo "Bandwidth Usage of $interface"
    printf "%10s %6d %3s   \n" \
      "Incoming:" $rx "MiB"\
      "Outgoing:" $tx "MiB"
done
