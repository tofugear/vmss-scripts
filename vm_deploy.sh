#!/bin/bash
set -e

# install base machine packages
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - 
echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt -y install build-essential yarn

# setup webuser 
sudo adduser --disabled-password --gecos "" webuser

# install nvm on webuser 
chmod o+x /var/deploy/install_nvm.sh 
sudo -u webuser -i bash -c /var/deploy/install_nvm.sh
chmod o-x /var/deploy/install_nvm.sh 

nvmsh = "source ~/.nvm/nvm.sh;"

cmd = "$nvmsh yarn global add pm2"

# install pm2
sudo -u webuser -i bash -c $cmd
