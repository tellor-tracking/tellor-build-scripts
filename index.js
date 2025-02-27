const shelljs = require('shelljs');
const fs = require('fs');
const rimraf = require('rimraf');

const FINAL_DIR = `${__dirname}/packages`;
const TEMP_DIR = `${__dirname}/temp`;
const PACKAGE_NAME = `tellor-${process.argv[2] || getNextPackageVersion()}`;
const API_PROJECT = 'tellor-web-server';
const UI_PROJECT = 'tellor-ui';
const WEB_SDK_PROJECT = 'tellor-web-sdk';


function cloneRepo(projectName) {
    const repoUrl = `https://github.com/tellor-tracking/${projectName}.git`;
    const dirName = projectName;
    console.log(`Cloning ${repoUrl}`);
    return shellExec(`git clone ${repoUrl} ${TEMP_DIR}/${dirName}`, `Successfully cloned ${repoUrl} into ${dirName}`);
}

function installPackages(dirName, prodOnly = false) {
    console.log(`Installing packages in  ${dirName}`);
    return shellExec(`(cd ${TEMP_DIR}/${dirName} ; yarn install ${prodOnly ? '--production' : ''})`, `Successfully installed packages in ${dirName}`);
}

function getNextPackageVersion() {
    return fs.readdirSync(FINAL_DIR).reduce((version, fileName) => {
        if (fileName.indexOf('tellor') === -1) return version;
        const v = parseFloat(fileName.split('-')[1])
        return version > v ? version : v;
    }, 0) + 1;
};

function buildUI() {
    console.log('Building UI');
    return shellExec(`(cd ${TEMP_DIR}/${UI_PROJECT}; yarn run build-dist)`, `Successfully build ${UI_PROJECT}`);
}

function moveUIDistFilesIntoServerDir() {
    shelljs.mkdir('-p', `${TEMP_DIR}/${API_PROJECT}/public/react`);
    shelljs.mv(`${TEMP_DIR}/${UI_PROJECT}/dist/*`, `${TEMP_DIR}/${API_PROJECT}/public/react/`);
    shelljs.rm('-rf', `${TEMP_DIR}/${UI_PROJECT}`);
    console.log('Copied UI static files into API');
    return Promise.resolve();
}

function buildWebSdk() {
    console.log('Building Web Sdk');
    return shellExec(`(cd ${TEMP_DIR}/${WEB_SDK_PROJECT}; yarn run build)`, `Successfully build ${WEB_SDK_PROJECT}`);
}

function moveWebSdkDistFilesIntoServerDir() {
    shelljs.mv(`${TEMP_DIR}/${WEB_SDK_PROJECT}/dist/*`, `${TEMP_DIR}/${API_PROJECT}/public/`);
    shelljs.rm('-rf', `${TEMP_DIR}/${WEB_SDK_PROJECT}`);
    console.log('Copied Web Sdk static files into API');
    return Promise.resolve();
}

function runApiTests() {
    console.log('Running Api tests');
    return shellExec(`(cd ${TEMP_DIR}/${API_PROJECT}; yarn run test)`, 'Successfully passed Api tests');
}


function renameApiDir() {
    shelljs.mv(`${TEMP_DIR}/${API_PROJECT}`, `${TEMP_DIR}/${PACKAGE_NAME}`);
}

function copyInstallScriptsIntoTempDir() {
    shelljs.cp(`${__dirname}/scripts/*`, `${TEMP_DIR}/`);
    shelljs.chmod('755', `${TEMP_DIR}/*`);
    console.log('Copied scripts');
    return Promise.resolve();
}

function copyConfigsIntoTempDir() {
    shelljs.mkdir('-p', `${TEMP_DIR}/configs`);
    shelljs.cp(`${__dirname}/configs/*`, `${TEMP_DIR}/configs/`);
    console.log('Copied configs');
    return Promise.resolve();
}

function createMakeselfFile() {
    // we will create an sh file at /packages that is able to self-extract and run install.sh. 
    // More at https://github.com/megastep/makeself

    return shellExec(
        `(cd ${FINAL_DIR} ; ${__dirname}/makeself/makeself.sh ${TEMP_DIR} ${PACKAGE_NAME}.sh "Tellor install script" ./install.sh)`,
        'Successfully created makeself.sh');
}

function createVersionsFile() {
    return new Promise((resolve, reject) => {
        console.log('Creating versions file');
        const versions = fs.readdirSync(FINAL_DIR)
        .filter(fileName => fileName.indexOf('tellor') !== -1)
        .sort((prev, next) => parseFloat(next.replace(/[^\d.]/g, '')) - parseFloat(prev.replace(/[^\d.]/g, '')));

        fs.writeFile(`${__dirname}/VERSIONS`, versions.join('\n'), err => err ? reject(err) : resolve());
    });
}

function cleanup() {
    rimraf(TEMP_DIR, (r) => console.log('Cleanup done'));
}

function resolveIfNeeded(resolve, reject, successMsg = null) {
    return (code, stdout, stderr) => {
        if (code !== 0) reject(new Error('Build failed' + stderr));
        console.log(stderr);
        successMsg && console.log(successMsg);
        resolve({ code, stdout, stderr });
    };
}

function shellExec(command, successMsg = null) {
    return new Promise((resolve, reject) => {
        shelljs.exec(command, { silent: true }, resolveIfNeeded(resolve, reject, successMsg));
    });
}

createVersionsFile();

Promise.all([cloneRepo(API_PROJECT), cloneRepo(UI_PROJECT), cloneRepo(WEB_SDK_PROJECT)])
    .then(() => Promise.all([
        installPackages(API_PROJECT),
        installPackages(UI_PROJECT),
        installPackages(WEB_SDK_PROJECT)
    ]))
    .then(runApiTests)
    .then(buildUI)
    .then(moveUIDistFilesIntoServerDir)
    .then(buildWebSdk)
    .then(moveWebSdkDistFilesIntoServerDir)
    .then(copyInstallScriptsIntoTempDir)
    .then(copyConfigsIntoTempDir)
    .then(renameApiDir)
    .then(createMakeselfFile)
    .then(createVersionsFile)
    .catch(e => console.error(e))
    .then(cleanup);



