#!/usr/bin/env bash

set -e
set -o pipefail

if [[ ${TRAVIS_OS_NAME} == "linux" ]]; then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
  source ~/.nvm/nvm.sh
fi

nvm install ${NODE_VERSION}
nvm alias default ${NODE_VERSION}
nvm use ${NODE_VERSION}

node --version
npm --version

if [[ ${TRAVIS_OS_NAME} == "linux" ]]; then
  export DISPLAY=:99.0
  sudo sh -e /etc/init.d/xvfb start
  sleep 5
fi
