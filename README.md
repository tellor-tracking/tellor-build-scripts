
# What

This repo contains build scripts for building distribution packs for tellor event analytics.

# How

Running `node index.js [optional-package-version]` will clone UI and API repos, build them, add install scripts and
dependency configs (mongodb, nginx) and package it all in one file with `makeself.sh` and place it at **/packages**.

To install tellor from this package all you need to do is run it: `sudo package-name.sh`;

After installing you can update to new version by running `tellor update` or by installing package with wanted
version and running it.

**Currently supports centos 7**.
