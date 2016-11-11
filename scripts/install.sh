#!/bin/sh

echo  "Starting setup";

DIR="$( pwd )"

if [ -f /etc/lsb-release ]; then
    bash $DIR/install_ubuntu.sh
elif [ -f /etc/redhat-release ]; then
    bash $DIR/install_centos.sh
fi

if hash yum 2>/dev/null; then
    echo "yum it is"
fi

hash mongo 2>/dev/null || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }


if ! which nginx > /dev/null 2>&1; then
    echo "Nginx not installed"
fi
