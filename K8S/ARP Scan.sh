#!/bin/bash

# Define the networks you want to scan
networks=("10.3.0" "10.3.1" "10.5.0")

for net in "${networks[@]}"; do
    echo "Scanning subnet: $net.x"
    for host in $(seq 1 254); do
        ip="$net.$host"
        ping -c 1 -W 1 $ip > /dev/null 2>&1 && echo "Active: $ip" &
    done
    wait
done

echo "Scan complete."