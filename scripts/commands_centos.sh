#!/bin/sh

if [[ $EUID -ne 0 ]]; then
    echo "You must run this with root" ;
    exit 1;
fi

function getVersion() {
    echo "$( ls /opt/tellor | grep tellor | sort -V | tail -1 | tr -d -c 0-9.)" # matches version like 11.1.    
}

function tellor_status() {

    VERSION=$(getVersion); 
    su - tellor -c 'P=/opt/tellor/tellor-'$VERSION'; $P/node_modules/pm2/bin/pm2 ls;'
}

function tellor_stop() {

    VERSION=$(getVersion); 
    su - tellor -c 'P=/opt/tellor/tellor-'$VERSION'; $P/node_modules/pm2/bin/pm2 stop tellor;'
}

function tellor_restart() {

    VERSION=$(getVersion); 
    su - tellor -c 'P=/opt/tellor/tellor-'$VERSION'; $P/node_modules/pm2/bin/pm2 restart tellor;'
}

function tellor_update() {

    hash git 2>/dev/null || { yum -y install git; } # install git if doesn't exist

    cd /opt/tellor
    CURRENT_VERSION="$( ls | grep tellor | sort -V | tail -1 | tr -d -c 0-9)";

    mkdir -p /opt/tellor/temp
    
    NEWEST_PACKAGE=$(curl https://raw.githubusercontent.com/tellor-tracking/tellor-build-scripts/master/VERSIONS | grep tellor | head -1)
    NEWEST_VERSION="$( echo $NEWEST_PACKAGE | tr -d -c 0-9)"; # matches just number so 11.1 > 111

    echo "Current ${CURRENT_VERSION}";
    echo "Newest ${NEWEST_VERSION}";

    if [ "$NEWEST_VERSION" -gt "$CURRENT_VERSION" ]; then
        echo "install new!";
        wget -P /opt/tellor/temp https://raw.githubusercontent.com/tellor-tracking/tellor-build-scripts/master/packages/$NEWEST_PACKAGE
        sudo sh /opt/tellor/temp/$NEWEST_PACKAGE
    else
        echo "You have most recent version";
    fi

    rm -rf /opt/tellor/temp;
}

tellor_rollback() {
    
    VERSION=$1;
    if [ -z "$1" ]; then
        VERSION="$(ls /opt/tellor | grep tellor | sort -V | head -n -1 | tail -1 | tr -d -c 0-9. )"; # match before last
    fi
        
    echo "rollbacking to version $VERSION";
    su - tellor -c 'P=/opt/tellor/tellor-'$VERSION'; $P/node_modules/pm2/bin/pm2 stop tellor; $P/node_modules/pm2/bin/pm2 delete tellor; $P/node_modules/pm2/bin/pm2 start $P/pm2.config.js'
}

tellor_dbpath() {

    if [ -z "$1" ]; then
        echo "You must provide absolute path"; exit 1;
    fi

    OLD_DATA_PATH=$( echo $( cat /etc/mongod.conf | grep 'dbPath:.*') | sed 's/dbPath://' );
    NEW_DATA_PATH=$(echo $1 | sed -e 's/[]\/$*.^|[]/\\&/g'); 

    sudo tellor stop;
    systemctl stop mongod;

    sed -i -e 's/dbPath:.*/dbPath: '$NEW_DATA_PATH'/g' /etc/mongod.conf;
    
    cp -ca $OLD_DATA_PATH/* $1;
    chown mongod:mongod $1;

    systemctl restart mongod;
    sudo tellor restart;
    echo "path $NEW_DATA_PATH set";
}

COMMAND=$1

if [ "$(type -t tellor_$COMMAND)" = function ]; then
    shift;
    tellor_${COMMAND} "$@";
else
    echo "Tellor available commands:";
    echo "    tellor update  # check if there is new version available and updates tellor if there is"
    echo "    tellor rollback [version]  # rollback to last or specified version"
    echo "    tellor dbpath  # sets data storage path for mongodb"       
    echo "    tellor restart # restarts tellor server"        
    echo "    tellor stop # stops tellor server"        
    echo "    tellor status # tellor server status info"        
fi