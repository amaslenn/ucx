#!/bin/bash -eE

eval "$*"
initial_delay=${initial_delay:=10}
cycles=${cycles:=2}
downtime=${downtime:=5}
uptime=${uptime:=20}

echo "Initial delay ${initial_delay} sec"
sleep ${initial_delay}

for i in $(seq 1 ${cycles} 1); do
    echo "#$i Put it down! And sleep ${downtime}"; sleep "$downtime"
    echo "#$i Put it up! And sleep ${uptime}"; sleep "$uptime"
done
