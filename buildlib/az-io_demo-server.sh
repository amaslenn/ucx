#!/bin/bash -leE

basedir=$(cd $(dirname $0) && pwd)
workspace=${WORKSPACE:="$basedir"}
cd "$workspace"

eval "$*"
source "${workspace}/az-helpers.sh"

ip addr show bond0
server_ip=$(ip addr show bond0 | awk '/inet / {print $2}' | awk -F/ '{print $1}')
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
