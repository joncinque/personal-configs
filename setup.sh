#! /usr/bin/env bash

DIR=$(dirname "$0")
cd "$DIR" || exit
FULLDIR=$(pwd)

INSTALL_GUI=false
INSTALL_EXTRA=false
RASPBERRY_PI=false
RELEASE=$(lsb_release -is)

echo "Base dev software"
echo "* Install base requirements"
sudo apt install -y curl git tmux neovim lld

echo "* Install fish"
echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_11/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_11/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg > /dev/null
sudo apt update
sudo apt install -y fish

# Diff and setup each config
echo "Setting up all config files as symlinks"
for FILE in '.bashrc' '.gitconfig' '.gitignore_global' '.tmux.conf' '.inputrc'
do
  echo "Working on: $FILE"
  if [ -e ~/$FILE ]
  then
    echo "Existing file found, diff:"
    diff ~/$FILE "$FULLDIR"/$FILE
    rm -i ~/$FILE
  fi
  "* Setting up link to $FULLDIR/$FILE"
  ln -s "$FULLDIR"/$FILE ~
done
echo "* Setting up link to $FULLDIR/.ssh/config"
mkdir -p ~/.ssh
ln -s "$FULLDIR"/ssh_config ~/.ssh/config

echo "* Setting up link to $FULLDIR/init.vim"
mkdir -p ~/.config/nvim
ln -s "$FULLDIR"/init.vim ~/.config/nvim

echo "* Setting up link to $FULLDIR/config.fish"
mkdir -p ~/.config/fish
ln -s "$FULLDIR"/config.fish ~/.config/fish

echo "* Setting up link to $FULLDIR/1.ctags"
mkdir -p ~/.config/ctags
ln -s "$FULLDIR"/1.ctags ~/.config/ctags

echo "* Setting up link to $FULLDIR/flake8"
ln -s "$FULLDIR"/flake8 ~/.config

echo "* Setting up link to add emojis to Hack"
mkdir -p ~/.config/fontconfig/conf.d
ln -s "$FULLDIR"/fontconfig/99-hack-color-emoji.conf ~/.config/fontconfig/conf.d

echo "* Setting up Plugged for vim plugins in init.vim"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Coding software"
echo "* Install python dev requirements"
sudo apt install -y python3-dev python3-pip python3-venv

echo "* Install global pynvim, flake8, mypy"
sudo pip3 install pynvim flake8 mypy

echo "* Install and setup powerline-status"
pip install git+https://github.com/powerline/powerline
pip install pomo-fish-powerline
echo "* Setting up link to $FULLDIR/powerline"
ln -s "$FULLDIR"/powerline ~/.config

echo "* Install n"
curl -L https://git.io/n-install | bash

echo "* Install required npm packages for vim, typescript, reveal, and yarn"
sudo PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true ~/n/bin/npm install -g neovim typescript ts-node reveal-md yarn

echo "* Install nvim plugins"
cd ~ || exit
vim +PlugInstall

#vim -c 'CocInstall -sync coc-json coc-html coc-prettier coc-tsserver coc-eslint coc-pyright coc-rls coc-rust-analyzer|q'
# vim +UpdateRemotePlugins

echo "* Install Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "* Setting up link to $FULLDIR/config.toml"
ln -s "$FULLDIR"/config.toml ~/.cargo

#echo "* Install rls and rust-analyzer"
#~/.cargo/bin/rustup toolchain add nightly
#~/.cargo/bin/rustup component add rust-src rust-analysis rls

#echo "* Install bandwhich"
#~/.cargo/bin/cargo install bandwhich

echo "* Install ruby and Jekyll for static pages"
sudo apt install -y ruby-dev build-essential zlib1g-dev
sudo gem install bundler

#echo "* Setup supervisor"
#echo_supervisord_conf | sudo tee /etc/supervisor/supervisord.conf
#echo '[include]
#files=conf.d/*.conf' | sudo tee -a /etc/supervisor/supervisord.conf
#echo '[Unit]
#Description=Supervisor daemon
#Documentation=http://supervisord.org
#After=network.target
#[Service]
#ExecStart=/usr/local/bin/supervisord -n -c /etc/supervisor/supervisord.conf
#ExecStop=/usr/local/bin/supervisorctl $OPTIONS shutdown
#ExecReload=/usr/local/bin/supervisorctl $OPTIONS reload
#KillMode=process
#Restart=on-failure
#RestartSec=42s
#[Install]
#WantedBy=multi-user.target
#Alias=supervisord.service' | sudo tee /etc/systemd/system/supervisord.service
#sudo systemctl daemon-reload
#sudo systemctl start supervisord

if [ "$RELEASE" = "Debian" ]; then
  echo "* Install nginx"
  deb https://nginx.org/packages/debian/ bullseye nginx
  deb-src https://nginx.org/packages/debian/ bullseye nginx
  sudo apt update
  sudo apt install -y nginx

  echo "* Install docker"
  sudo apt remove -y docker docker-engine docker.io containerd runc
  sudo apt install -y ca-certificates gnupg lsb-release
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo usermod -aG docker "$USER"
  sudo systemctl restart docker.service
fi

if [ "$RELEASE" = "Ubuntu" ]; then
  echo "* Install docker"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io
  # not needed since the group is added on instsall
  # sudo groupadd docker
  sudo usermod -aG docker "$USER"
  sudo systemctl restart docker.service
  # testing
  # docker run hello-world
fi

if [ "$INSTALL_EXTRA" = true ]; then
  echo "* Install dotnet core"
  wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  sudo apt install -y dotnet-sdk-2.1

  echo "* Install mongodb 4.2"
  wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
  echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
  sudo apt update
  sudo apt install -y mongodb-org

  echo "* Install influxdb"
  wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
  source /etc/lsb-release
  echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
  sudo apt update
  sudo apt install -y influxdb
  sudo systemctl start influxdb

  echo "* Install postgres"
  sudo apt install -y postgresql

  echo "* Install nginx"
  sudo add-apt-repository ppa:nginx/stable
  sudo apt install -y nginx

  echo "Installing gcloud CLI" # https://cloud.google.com/sdk/gcloud/
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
  sudo apt update
  sudo apt install google-cloud-sdk
  gcloud init
  gcloud auth configure-docker
fi

if [ "$INSTALL_GUI" = true ]; then
  echo "GUI applications"
  echo "* Install meld (diffing), remmina (RDP to Windows), firefox"
  sudo apt install -y meld remmina firefox

  echo "* Install tixati"
  wget 'https://download2.tixati.com/download/tixati_2.83-1_amd64.deb'
  sudo dpkg -i tixati_2.83-1_amd64.deb

  echo "* Install discord"
  wget 'https://discord.com/api/download?platform=linux&format=deb' -O discord.deb
  sudo dpkg -i discord.deb

  echo "* Install pandoc: check https://github.com/jgm/pandoc/releases for deb"
  echo "* Install texlive, pandoc requirement for pdf"
  sudo apt install texlive

  echo "* Install brave browser"
  curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
  echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update
  sudo apt install brave-browser

  echo "* Install telegram"
  sudo apt install telegram-desktop

  echo "* Setup udev for ledger"
  wget -q -O - https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo bash

  echo "* Install slack"
  echo "You will need to do this yourself, please confirm when this is done"
  read -r nothing
  echo "$nothing"
fi

if [ "$RASPBERRY_PI" = true ]; then
  sudo pip3 install RPi.GPIO
fi

# WINDOWS ONLY
# steam
# windows terminal + keys and setups

# GitHub ssh token
# GITHUB_FILE=/home/jon/.ssh/github_id_rsa
# echo "$GITHUB_FILE" | ssh-keygen -t rsa -b 4096 -C "joncinque@pm.me"
# echo "* Add public key to GitHub:"
# cat "$GITHUB_FILE".pub
