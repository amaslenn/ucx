#!/bin/bash -leE

basedir=$(cd $(dirname $0) && pwd)
workspace=${workspace:=$(pwd)}
cd "$workspace"

eval "$*"
IP=${IP:=""}
duration=${duration:=2}

source "${workspace}/az-helpers.sh"
if [ "x$IP" = "x" ]; then
    error "Server IP is not set (env var 'IP')"
fi

timeout="$(( duration - 1 ))m"
# avoid err: TERM environment variable not set
export TERM=xterm

echo "Server IP is $IP"
echo "Timeout is $timeout"

ip addr show bond0
ping -c 2 $IP

source "${workspace}/../test/apps/iodemo/env"
if ! "${workspace}/../test/apps/iodemo/io_demo" -l $timeout -i 10000000 $IP >client.log 2>&1 & then
    cat client.log
    error "Failed to start client"
fi
client_pid=$!

# double check the process is running
sleep 3
if ! kill -0 $client_pid; then
    cat client.log
    error "Error in client"
fi
echo "Client is running, PID=$client_pid"

# TODO: implement network corruptions

if ! wait $client_pid; then
    cat client.log
    error "Error in client"
else
    cat client.log
    echo "Client exited successfully"
fi
