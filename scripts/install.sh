#!/bin/sh

echo  "Starting setup";

CURRENT_DIR="$( pwd )"
TARGET_DIR="/opt/tellor"
FILE_NAME="$( ls | grep tellor | tail -1)"

if [ -z "$FILE_NAME" ];then
    echo "Can't find fist file"
    exit 1;
fi

if [ -f /etc/lsb-release ]; then
    (. ./install_centos.sh)
elif [ -f /etc/redhat-release ]; then
   (. ./install_centos.sh)
fi

if hash yum 2>/dev/null; then
    echo "yum it is"
fi

hash mongo 2>/dev/null || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }