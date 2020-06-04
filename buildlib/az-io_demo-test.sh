#!/bin/bash -leE

basedir=$(cd $(dirname $0) && pwd)
workspace=${WORKSPACE:="$basedir"}
cd "$workspace"

eval "$*"
source "${workspace}/az-helpers.sh"

IP=${IP:=""}
duration=${duration:=2}

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
if ! "${workspace}/../test/apps/iodemo/io_demo" -l $timeout -i 10000000 $IP; then
    error "Failed to start client"
fi
