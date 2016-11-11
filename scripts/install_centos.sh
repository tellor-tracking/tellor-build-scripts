#!/bin/sh

# install node

# install nginx if needed
# config nginx

# install mongodb if needed
# config mongodb

# copy self; start server

mkdir -p $TARGET_DIR/ && mv $CURRENT_DIR/$FILE_NAME $TARGET_DIR/
cd $CURRENT_DIR/$FILE_NAME && node app.js