#!/bin/sh

# hash mongo 2>/dev/null || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }


# install node
curl --silent --location https://rpm.nodesource.com/setup_7.x | bash -
yum -y install nodejs

#instal pm2
npm i -g pm2

# install nginx if needed
echo "[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/x86_64/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/nginx.repo

yum -y install nginx

# config nginx
cp $CURRENT_DIR/configs/nginx.server.conf /etc/nginx/conf.d/default.conf
cp $CURRENT_DIR/configs/nginx.conf /etc/nginx/nginx.conf

#TODO

#start nginx
systemctl restart nginx


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
 node $TARGET_DIR/$FILE_NAME/run.js