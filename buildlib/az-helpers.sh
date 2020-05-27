#!/bin/bash -eE

RUNNING_IN_AZURE="yes"
if [ -z "$AGENT_ID" ]; then
    RUNNING_IN_AZURE="no"
fi

function error() {
    msg=$1
    azure_log_issue "${msg}"
    echo "ERROR: ${msg}"
    exit 1
}

function azure_set_variable() {
    test "x$RUNNING_IN_AZURE" = "xno" && return
    name=$1
    value=$2
    echo "##vso[task.setvariable variable=${name}]${value}"
}

function azure_log_issue() {
    test "x$RUNNING_IN_AZURE" = "xno" && return
    msg=$1
    echo "##vso[task.logissue type=error]${msg}"
    echo "##vso[task.complete result=Failed;]"
}
