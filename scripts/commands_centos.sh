#!/bin/sh

function tellor_restart() {
    echo "restart TODO";
}

function tellor_update() {

    if [[ $EUID -ne 0 ]]; then
        echo "You must run this with root" ;
        exit 1;
    fi

    if [ hash git 2>/dev/null ]; then
        yum -y install git;
    fi

    cd /opt/tellor
    CURRENT_VERSION="$( ls | grep tellor | tail -1 | tr -d -c 0-9)";

    mkdir -p /opt/tellor/temp
    git clone "https://github.com/tellor-tracking/tellor-build-scripts.git" /opt/tellor/temp;
    NEWEST_VERSION="$( ls /opt/tellor/temp/packages | grep tellor | tail -1 | tr -d -c 0-9)"; # matches just number so 11.1 > 111

    echo "Current ${CURRENT_VERSION}";
    echo "Newest ${NEWEST_VERSION}";

    if [ "$NEWEST_VERSION" -gt "$CURRENT_VERSION" ]; then
        echo "install new!";
        VERSION_FULL="$( ls /opt/tellor/temp/packages | grep tellor | tail -1 | tr -d -c 0-9.)" # matches version like 11.1.
        sudo /opt/tellor/temp/packages/tellor-${VERSION_FULL}sh
    else
        echo "You have most recent version";
    fi

    rm -rf /opt/tellor/temp;
}

tellor_rollback() {
    

    if [ -z "$1" ]; then
        VERSION="$(ls /opt/tellor | grep tellor | tail -1 | tr -d -c 0-9.)";
    else 
        VERSION=$1;
    fi
        
    echo "rollbacking to version $VERSION";
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