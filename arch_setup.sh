#!/usr/bin/env bash

DIR=$(dirname "$0")
cd "$DIR" || exit
FULLDIR=$(pwd)

INSTALL_GUI=true
INSTALL_EXTRA=false

echo "Base dev software"
echo "* Install base requirements"
sudo pacman --noconfirm -Syu

echo "* Install base dev stuff"
sudo pacman --noconfirm -S curl git tmux neovim fish base-devel

echo "* Switch to fish"
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

"* Setting up link from vim to nvim"
sudo ln -s /usr/bin/nvim /usr/bin/vim
sudo ln -s /usr/bin/nvim /usr/bin/vi

"* Setting up link to $FULLDIR/config.fish"
mkdir -p ~/.config/fish
ln -s "$FULLDIR"/config.fish ~/.config/fish

"* Setting up link to $FULLDIR/flake8"
ln -s "$FULLDIR"/flake8 ~/.config

echo "* Setting up Plugged for vim plugins in init.vim"
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

echo "Coding software"
echo "* Install python dev requirements"
sudo pacman --noconfirm -S python python-pip python-pipenv

echo "* Install global pynvim, flake8, mypy"
sudo pip install pynvim flake8 mypy

echo "* Install n"
curl -L https://git.io/n-install | bash

echo "* Install required npm packages for vim, typescript, reveal, and yarn"
sudo PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true ~/n/bin/npm install -g neovim typescript ts-node reveal-md yarn

echo "* Install nvim plugins"
cd ~ || exit
nvim +PlugInstall

echo "* Install Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "* Install rls and rust-analyzer"
~/.cargo/bin/rustup toolchain add nightly
~/.cargo/bin/rustup component add rust-src rust-analysis rls

echo "* Install ruby and Jekyll for static pages"
sudo apt install -y ruby zlib
sudo gem install bundler

echo "* Install docker"
sudo pacman --noconfirm -S docker
sudo usermod -aG docker "$USER"
# sudo systemctl restart docker.service
# testing
# docker run hello-world

function install_from_aur() {
  package_name="$1"
  package_dir="$FULLDIR"/"$package_name"
  git clone https://aur.archlinux.org/"$package_name".git "$package_dir"
  cd "$package_dir"
  makepkg
  sudo pacman --noconfirm -U "$package_name"*pkg.tar.zst
  cd "$FULLDIR"
  rm -rf "$package_dir"
}

if [ "$INSTALL_EXTRA" = true ]; then
  echo "Installing gcloud CLI" # https://cloud.google.com/sdk/gcloud/
  install_from_aur google-cloud-sdk
  gcloud init
  gcloud auth configure-docker
  cd "$FULLDIR"
fi

if [ "$INSTALL_GUI" = true ]; then
  echo "GUI applications"
  echo "* Install firefox"
  sudo pacman --noconfirm -S firefox

  echo "* Install tixati"
  sudo pacman --noconfirm -S gtk2 traceroute
  install_from_aur tixati

  echo "* Install discord"
  sudo pacman --noconfirm -S electron16
  install_from_aur discord_arch_electron

  echo "* Install brave browser"
  install_from_aur brave-bin

  echo "* Install telegram"
  sudo pacman --noconfirm -S telegram-desktop

  echo "* Setup udev for ledger"
  wget -q -O - https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo bash

  echo "* Install slack"
  install_from_aur slack-desktop
fi

# GitHub ssh token
# GITHUB_FILE=/home/jon/.ssh/github_id_rsa
# echo "$GITHUB_FILE" | ssh-keygen -t rsa -b 4096 -C "jon.cinque@gmail.com"
# echo "* Add public key to GitHub:"
# cat "$GITHUB_FILE".pub