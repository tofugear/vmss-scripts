#!/bin/bash
set -e

# install base machine packages
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - 
echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt -y install build-essential yarn

# setup webuser if webuser not yet created 
if [ ! `id -u webuser 2>/dev/null || echo -1` -ge 0 ] then
    sudo adduser --disabled-password --gecos "" webuser
fi

# install nvm on webuser 
chmod o+x /var/deploy/install_nvm.sh 
sudo -u webuser -i bash -c /var/deploy/install_nvm.sh
chmod o-x /var/deploy/install_nvm.sh 

nvmsh = "source ~/.nvm/nvm.sh;"

# install node via nvm
sudo -u webuser -i bash -c "$nvmsh nvm install v7.5"

# install pm2
sudo -u webuser -i bash -c "$nvmsh yarn global add pm2"
