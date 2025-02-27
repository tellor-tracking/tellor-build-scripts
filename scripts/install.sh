#!/bin/sh

if [[ $EUID -ne 0 ]]; then
    echo "You must run this with root" ;
    exit 1;
fi

echo  "Starting setup";

CURRENT_DIR="$( pwd )"
TARGET_DIR="/opt/tellor"
FILE_NAME="$( ls | grep tellor | tail -1)"
LOGS_DIR="/var/log/tellor"

if [ -z "$FILE_NAME" ];then
    echo "Can't find file"
    exit 1;
fi

# mv server dir
mkdir -p $TARGET_DIR/ && mv $CURRENT_DIR/$FILE_NAME $TARGET_DIR/

# create user
useradd -U -d $TARGET_DIR tellor

# ensure logs dir with correct user
mkdir -p $LOGS_DIR
chown tellor:tellor $LOGS_DIR

# ensure server dir owner
chown -R tellor:tellor $TARGET_DIR


if [ -f /etc/lsb-release ]; then
    (. ./install_centos.sh)
elif [ -f /etc/redhat-release ]; then
   (. ./install_centos.sh)
fi