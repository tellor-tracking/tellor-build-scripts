#!/bin/sh

# hash mongo 2>/dev/null || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }


# install node
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
sudo apt-get install -y nodejs

# install nginx if needed
sudo apt-get update
sudo apt-get install nginx

# config nginx

# install mongodb if needed

echo "[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/3.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc" > /etc/yum.repos.d/mongodb-org.repo

sudo yum -y install mongodb-org

# config mongodb
# TODO

# start mongo
systemctl restart mongod

# start server
# /home/vytenis/.nvm/versions/node/v6.6.0/bin/node $TARGET_DIR/$FILE_NAME/run.js #TODO replace with node