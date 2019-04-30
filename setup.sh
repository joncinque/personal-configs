#! /usr/bin/env bash

DIR=$(dirname "$0")
cd "$DIR"
FULLDIR=$(pwd)

echo "Installing dev requirements"
sudo apt install -y neovim curl git tmux

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
  "Setting up link to $FULLDIR/$FILE"
  ln -s "$FULLDIR"/$FILE ~
done
"Setting up link to $FULLDIR/init.vim"
mkdir -p ~/.config/nvim
ln -s "$FULLDIR"/init.vim ~/.config/nvim

echo "Setting up Plugged for vim plugins in init.vim"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Installing extra needed plugins"
cd ~
vim +PlugInstall

echo "Installing dev requirements"
sudo apt install -y python3-dev python3-pip python3-venv

echo "Install ansible"
sudo pip3 install ansible

#echo "Installing spotify"
sudo snap install spotify

#echo "Installing discord"
sudo snap install discord

#echo "Installing VS Code"
sudo snap install vscode

echo "Installing docker"
sudo snap install docker
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl restart snap.docker.dockerd
# testing
# docker run hello-world

# influxdb
# mongodb
# node 10
# typescript
# ts-node
# dotnet core
# firefox
# ng
# meld
# remmina
# postgres
# tixati
# nginx
# ocaml
# graphite + graphite api

# WINDOWS ONLY
# steam
# visual studio
# putty + keys and setups
# discord
