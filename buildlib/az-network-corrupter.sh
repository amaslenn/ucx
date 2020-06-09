#!/bin/bash -eE

eval "$*"
initial_delay=${initial_delay:=10}
cycles=${cycles:=1000}
downtime=${downtime:=5}
uptime=${uptime:=20}
reset=${reset:="no"}


if [ "x$reset" = "xyes" ]; then
    echo "Resetting interface on $(hostname)..."
    sudo /hpc/noarch/git_projects/swx_infrastructure/clusters/bin/manage_host_ports.sh "$(hostname)" "bond-up"
    exit $?
fi

echo "Initial delay ${initial_delay} sec"
sleep ${initial_delay}

for i in $(seq 1 ${cycles}); do
    echo "#$i Put it down! And sleep ${downtime}"
    sudo /hpc/noarch/git_projects/swx_infrastructure/clusters/bin/manage_host_ports.sh "$(hostname)" "bond-down"
    sleep "$downtime"

    echo "#$i Put it up! And sleep ${uptime}"
    sudo /hpc/noarch/git_projects/swx_infrastructure/clusters/bin/manage_host_ports.sh "$(hostname)" "bond-up"
    sleep "$uptime"
done
