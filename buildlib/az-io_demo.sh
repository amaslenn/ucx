#!/bin/bash -leE

# avoid Azure error: TERM environment variable not set
export TERM=xterm

basedir=$(cd $(dirname $0) && pwd)
workspace=${WORKSPACE:="$basedir"}
cd "$workspace"

eval "$*"
source "${workspace}/az-helpers.sh"

server_ip=${server_ip:=""}
duration=${duration:=2}
iface=${iface:="bond0"}

## run server
if [ "x$server_ip" = "x" ]; then
    ip addr show ${iface}
    server_ip=$(ip addr show ${iface} | awk '/inet / {print $2}' | awk -F/ '{print $1}')
    azure_set_variable "server_ip" "$server_ip"

    source "${workspace}/../test/apps/iodemo/env"
    if ! "${workspace}/../test/apps/iodemo/io_demo" >server.log 2>&1 & then
        error "Failed to start server"
    fi
    server_pid=$!
    echo "Server is running, PID=$server_pid"
    azure_set_variable "server_pid" "$server_pid"

    # double check the process is running
    sleep 3
    if ! kill -0 $server_pid; then
        cat server.log
        error "Failed to start server"
    fi

    exit 0
fi

## run client

timeout="$(( duration - 1 ))m"

echo "Server IP is $server_ip"
echo "Timeout is $timeout"

source "${workspace}/../test/apps/iodemo/env"
if ! "${workspace}/../test/apps/iodemo/io_demo" -l $timeout -i 10000000 "$server_ip"; then
    error "Failed to start client"
fi
