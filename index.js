const gulp = require('gulp');
const shelljs = require('shelljs');
const fs = require('fs');
const rimraf = require('rimraf');

const FINAL_DIR = `${__dirname}/packages`;
const TEMP_DIR = `${__dirname}/temp`;

const PACKAGE_VERSION = getNextPackageVersion();

const API_PROJECT = 'tellor-web-server';
const UI_PROJECT = 'tellor-ui';
const getGitRepoAddr = (name) => `https://github.com/tellor-tracking/${name}.git`

function cloneRepo(repoUrl, dirName = '') {
    console.log(`Cloning ${repoUrl}`);
    return shellExec(`git clone ${repoUrl} ${TEMP_DIR}/${dirName}`, `Successfully cloned ${repoUrl} into ${dirName}`);    
}

function installPackages(dirName, prodOnly = true) {
    console.log(`Installing packages in  ${dirName}`);    
    return shellExec(`(cd ${TEMP_DIR}/${dirName} ; yarn install ${prodOnly ? '--production' : ''})`, `Successfully installed packages in ${dirName}`);
}

function getNextPackageVersion() {
    return fs.readdirSync(FINAL_DIR).reduce((version, fileName) => {
        const v = parseFloat(fileName.split('-')[1])
        return version > v ? version : v;
    }, 0);
};

function buildUI() {
    console.log('Building UI');
    return shellExec(`(cd ${TEMP_DIR}/${UI_PROJECT} ; yarn run build-dist)`, `Successfully buil ${UI_PROJECT}`);
}

function copyUIIntoServerDir() {
    shelljs.mv(`${TEMP_DIR}/${UI_PROJECT}/dist`, `${TEMP_DIR}/${API_PROJECT}/public/react`);
    console.log('Copied UI static files into API');
    return Promise.resolve();
}

function cleanup() {
    rimraf(TEMP_DIR, (r) => console.log('Cleanup done'));
}

function resolveIfNeeded(resolve, reject, successMsg = null) {
    return (code, stdout, stderr) => {
            if (code !== 0) reject(new Error('Build failed' + stderr));
            
            successMsg && console.log(successMsg);
            resolve({ code, stdout, stderr });
        };
}

function shellExec(command, successMsg = null) {
    return new Promise((resolve, reject) => {
        shelljs.exec(command, {silent: true}, resolveIfNeeded(resolve, reject, successMsg));
    });
}


Promise.all([cloneRepo(getGitRepoAddr(API_PROJECT), API_PROJECT), cloneRepo(getGitRepoAddr(UI_PROJECT), UI_PROJECT)])
    .then(() => Promise.all([installPackages(API_PROJECT), installPackages(UI_PROJECT, false)]))
    .then(buildUI)
    .then(copyUIIntoServerDir)
    .catch(e => console.error(e));
    // .then(cleanup);



