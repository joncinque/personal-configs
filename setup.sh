#! /usr/bin/env bash

DIR=$(dirname "$0")
cd "$DIR"
FULLDIR=$(pwd)

INSTALL_GUI=false
INSTALL_EXTRA=false
RELEASE=$(lsb_release -is)

echo "Base dev software"
echo "* Install base requirements"
sudo apt install -y curl git tmux

echo "* Install neovim"
sudo apt-add-repository -y ppa:neovim-ppa/stable
sudo apt install -y neovim

echo "* Install fish"
sudo apt-add-repository -y ppa:fish-shell/release-3
sudo apt install -y fish
chsh -s /usr/bin/fish

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
"* Setting up link to $FULLDIR/.ssh/config"
mkdir -p ~/.ssh
ln -s "$FULLDIR"/ssh_config ~/.ssh/config

"* Setting up link to $FULLDIR/init.vim"
mkdir -p ~/.config/nvim
ln -s "$FULLDIR"/init.vim ~/.config/nvim

"* Setting up link to $FULLDIR/config.fish"
mkdir -p ~/.config/fish
ln -s "$FULLDIR"/config.fish ~/.config/fish

"* Setting up link to $FULLDIR/flake8"
ln -s "$FULLDIR"/flake8 ~/.config

echo "* Setting up Plugged for vim plugins in init.vim"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Coding software"
echo "* Install python dev requirements"
sudo apt install -y python3-dev python3-pip python3-venv

echo "* Install global ansible, pynvim, jedi, supervisor"
sudo pip3 install ansible pynvim jedi supervisor
# if needed, jedi had bugs back in 2020-02-02
#sudo pip3 install -e git://github.com/davidhalter/jedi.git#egg=jedi

echo "* Install node"
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install -y nodejs

echo "* Install required npm packages for vim, typescript, and reveal"
PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1 sudo npm install -g neovim typescript ts-node reveal-md

echo "* Install yarn"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install -y yarn

echo "* Install nvim plugins"
cd ~
vim +PlugInstall
vim +UpdateRemotePlugins

echo "* Install Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "* Install racer"
rustup toolchain add nightly
rustup component add rust-src
cargo +nightly install racer

echo "* Install bandwhich"
cargo install bandwhich

echo "* Install ruby and Jekyll for static pages"
sudo apt install ruby-dev build-essential zlib1g-dev
sudo gem install bundler

echo "* Setup supervisor"
echo_supervisord_conf | sudo tee /etc/supervisor/supervisord.conf
echo '[include]
files=conf.d/*.conf' | sudo tee -a /etc/supervisor/supervisord.conf
echo '[Unit]
Description=Supervisor daemon
Documentation=http://supervisord.org
After=network.target
[Service]
ExecStart=/usr/local/bin/supervisord -n -c /etc/supervisor/supervisord.conf
ExecStop=/usr/local/bin/supervisorctl $OPTIONS shutdown
ExecReload=/usr/local/bin/supervisorctl $OPTIONS reload
KillMode=process
Restart=on-failure
RestartSec=42s
[Install]
WantedBy=multi-user.target
Alias=supervisord.service' > | sudo tee /etc/systemd/system/supervisord.service
sudo systemctl daemon-reload
sudo systemctl start supervisord

if [ "$RELEASE" = "Ubuntu" ]; then
  echo "* Install dotnet core"
  wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  sudo apt install -y dotnet-sdk-2.1

  echo "* Install mongodb 4.2"
  wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
  echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
  sudo apt update
  sudo apt install -y mongodb-org

  echo "* Install docker"
  sudo snap install docker
  sudo groupadd docker
  sudo usermod -aG docker $USER
  sudo systemctl restart snap.docker.dockerd
  # testing
  # docker run hello-world

  echo "* Install go"
  sudo snap install --classic go
fi

if [ "$INSTALL_EXTRA" = true ]; then
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

  # graphite + graphite api

  #echo "Install opam / ocaml"
  #sudo add-apt-repository ppa:avsm/ppa
  #sudo apt install opam
  # Setting up compiler and all
  # opam init

  #echo "Install meteor"
  #curl https://install.meteor.com/ | sh

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
  wget https://download2.tixati.com/download/tixati_2.66-1_amd64.deb
  sudo dpkg -i tixati_2.66-1_amd64.deb

  echo "* Install VS Code for dotnet debugging"
  sudo snap install code

  echo "Non-programming applications"
  echo "* Install spotify"
  sudo snap install spotify

  echo "* Install discord"
  sudo snap install discord

  echo "* Install pandoc: check https://github.com/jgm/pandoc/releases for deb"
  echo "* Install texlive, pandoc requirement for pdf"
  sudo apt install texlive

  echo "* Install slack"
  sudo snap install slack --classic
fi

# WINDOWS ONLY
# steam
# visual studio
# windows terminal + keys and setups

# GitHub ssh token
GITHUB_FILE=/home/jon/.ssh/github_id_rsa
echo "$GITHUB_FILE" | ssh-keygen -t rsa -b 4096 -C "jon.cinque@gmail.com"
echo "* Add public key to GitHub:"
cat "$GITHUB_FILE".pub

