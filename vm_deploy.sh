#!/bin/bash
set -x -e

# install base machine packages
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - 
echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt -y install build-essential yarn

# setup webuser if webuser not yet created 
if [ ! `id -u webuser 2>/dev/null || echo -1` -ge 0 ]; then
    sudo adduser --disabled-password --gecos "" webuser
fi

# install nvm on webuser 
chmod o+x /var/deploy/install_nvm.sh 
sudo -u webuser -i bash -c /var/deploy/install_nvm.sh
chmod o-x /var/deploy/install_nvm.sh 

nvmsh="source ~/.nvm/nvm.sh;"

# install node via nvm
sudo -u webuser -i bash -c "$nvmsh nvm install v7.5"

# install pm2
sudo -u webuser -i bash -c "$nvmsh yarn global add pm2"

# deploy node js project
mkdir -p /var/www/tech-summit-2017-nodejs
chown tofugear:webuser /var/www/tech-summit-2017-nodejs
git clone git@bitbucket.org:tofugear/tech-summit-2017-nodejs.git /var/www/tech-summit-2017-nodejs

sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo env PATH=$PATH:/home/webuser/.nvm/versions/node/v7.5.0/bin /home/webuser/.config/yarn/global/node_modules/pm2/bin/pm2 startup systemd -u webuser --hp /home/webuser
sudo -u webuser -i bash -c "source ~/.nvm/nvm.sh; /home/webuser/.nvm/versions/node/v7.5.0/bin/pm2 start /var/www/tech-summit-2017-nodejs/bin/www --name techsummit"

