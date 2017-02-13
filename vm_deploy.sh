#!/bin/sh

# install base machine packages
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - 
echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt -y install build-essential yarn

# setup webuser 
sudo adduser --disabled-password --gecos "" webuser

# install nvm on webuser 
read -d '' install_nvm << EOF
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm' >> ~/.bashrc
source ~/.bashrc
EOF

sudo -u webuser -i bash -c $install_nvm

nvmsh = "source ~/.nvm/nvm.sh;"

# install pm2
sudo -u webuser -i bash -c '$nvmsh yarn global add pm2'
