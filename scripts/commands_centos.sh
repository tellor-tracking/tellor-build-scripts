#!/bin/sh

function tellor_restart() {
    echo "restart TODO";
}

function tellor_update() {
    if [ hash git 2>/dev/null ]; then
        yum -y install git;
    fi

    cd /opt/tellor
    CURRENT_VERSION="$( ls | grep tellor | tail -1 | tr -d -c 0-9)";

    mkdir -p /opt/tellor/temp
    git clone "https://github.com/tellor-tracking/tellor-build-scripts.git" /opt/tellor/temp;
    cd /opt/tellor/temp/packages;
    NEWEST_VERSION="$( ls | grep tellor | tail -1 | tr -d -c 0-9)";

    echo "Current ${CURRENT_VERSION}";
    echo "Newest ${NEWEST_VERSION}";

    if [ "$NEWEST_VERSION" -gt "$CURRENT_VERSION" ]; then
        echo "install new!";
    else
        echo "You have most recent version";
    fi

    rm -rf /opt/tellor/temp;
}

COMMAND=$1

if [ "$(type -t tellor_$COMMAND)" = function ]; then
    shift;
    tellor_${COMMAND} "$@";
else
    echo "Tellor available commands:";
    echo "    tellor update # check if there is new version available and updates tellor if there is"
    echo "    tellor restart # restarts tellor server"        
fi