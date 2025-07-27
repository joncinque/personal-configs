#!/usr/bin/env bash

DIR=$(dirname "$0")
cd "$DIR" || exit
FULLDIR=$(pwd)

INSTALL_GUI=true
INSTALL_EXTRA=false

DISTRO=$(lsb_release -i | cut -f 2-)
case $DISTRO in
Fedora)
  UPDATE_COMMAND="dnf upgrade --refresh -y"
  INSTALL_COMMAND="dnf install -y"
  ;;
Arch)
  UPDATE_COMMAND="pacman --noconfirm -Syu"
  INSTALL_COMMAND="pacman --noconfirm -S"
  ;;
Debian)
  UPDATE_COMMAND="apt update -y && apt upgrade -y"
  INSTALL_COMMAND="apt install -y"
  ;;
esac

echo "Base dev software"
echo "* Install base requirements"
sudo $UPDATE_COMMAND

echo "* Install base dev stuff"
sudo $INSTALL_COMMAND curl git tmux neovim fish base-devel xsel lld

echo "* Switch to fish"
chsh -s /usr/bin/fish

# Diff and setup each config
echo "Setting up all config files as symlinks"
for FILE in '.bashrc' '.gitconfig' '.gitignore_global' '.tmux.conf' '.inputrc' '.alacritty.toml' '.dircolors'
do
  echo "* Setting up link to $FULLDIR/$FILE"
  ln -si "$FULLDIR"/$FILE ~
done
echo "* Setting up link to $FULLDIR/.ssh/config"
mkdir -p ~/.ssh
ln -si "$FULLDIR"/ssh_config ~/.ssh/config

echo "* Setting up link to $FULLDIR/init.vim"
mkdir -p ~/.config/nvim
ln -si "$FULLDIR"/init.vim ~/.config/nvim

echo "* Setting up link from vim to nvim"
sudo ln -si /usr/bin/nvim /usr/bin/vim
sudo ln -si /usr/bin/nvim /usr/bin/vi

echo "* Setting up link to $FULLDIR/config.fish"
mkdir -p ~/.config/fish
ln -si "$FULLDIR"/config.fish ~/.config/fish/config.fish

echo "* Setting up link to $FULLDIR/flake8"
ln -si "$FULLDIR"/flake8 ~/.config

echo "* Setting up link to add emojis to Hack"
mkdir -p ~/.config/fontconfig/conf.d
ln -si "$FULLDIR"/fontconfig/99-hack-color-emoji.conf ~/.config/fontconfig/conf.d

echo "* Setting up link to $FULLDIR/git-cliff"
ln -si "$FULLDIR"/git-cliff ~/.config/

echo "* Setting up link to $FULLDIR/hyprland.conf"
ln -si "$FULLDIR"/hypr ~/.config/

echo "* Setting up link to $FULLDIR/waybar"
ln -si "$FULLDIR"/waybar ~/.config/

echo "* Setting up Plugged for vim plugins in init.vim"
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

echo "Coding software"
echo "* Install python dev requirements"
sudo $INSTALL_COMMAND python python-pip python-pipenv

echo "* Install global pynvim, flake8, mypy, lsp"
sudo pip install pynvim flake8 mypy python-lsp-server pylsp-mypy

echo "* Install n"
curl -L https://git.io/n-install | bash

echo "* Install required npm packages for vim"
sudo PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true ~/n/bin/npm install -g neovim typescript @biomejs/biome

echo "* Install nvim plugins"
cd ~ || exit
nvim +PlugInstall

echo "* Install Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "* Install rust-analyzer"
~/.cargo/bin/rustup toolchain add nightly
~/.cargo/bin/rustup component add rust-src rust-analyzer

echo "* Setting up link to $FULLDIR/config.toml"
ln -si "$FULLDIR"/config.toml ~/.cargo

#echo "* Install ruby and Jekyll for static pages"
#sudo apt install -y ruby zlib
#sudo gem install bundler

echo "* Install docker"
sudo $INSTALL_COMMAND docker
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

  echo "Installing openvpn DNS updater"
  install_from_aur openvpn-update-systemd-resolved

  sudo $INSTALL_COMMAND clang git-cliff difftastic
fi

if [ "$INSTALL_GUI" = true ]; then
  echo "GUI applications"
  echo "* Install emoji fonts"
  sudo $INSTALL_COMMAND noto-fonts-emoji

  echo "* Install firefox"
  sudo $INSTALL_COMMAND firefox

  echo "* Install tixati"
  sudo $INSTALL_COMMAND gtk2 traceroute dbus-glib
  install_from_aur tixati

  echo "* Install discord"
  sudo $INSTALL_COMMAND discord

  echo "* Install brave browser"
  install_from_aur brave-bin

  echo "* Install telegram"
  sudo $INSTALL_COMMAND telegram-desktop

  echo "* Setup udev for ledger"
  curl -sSfL https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo bash

  echo "* Install slack"
  install_from_aur slack-desktop

  echo "* Install signal"
  sudo $INSTALL_COMMAND signal-desktop

  echo "Replace pulse audio with pipewire"
  sudo $INSTALL_COMMAND pipewire pipewire-pulse

  echo "* Install hyprland and friends"
  sudo $INSTALL_COMMAND hyprland hypridle waybar pavucontrol brightnessctl power-profiles-daemon mako hyprpolkitagent hyprpaper
fi

# Zoom download + install
# GitHub ssh token
# GITHUB_FILE=/home/jon/.ssh/github_id_rsa
# echo "$GITHUB_FILE" | ssh-keygen -t rsa -b 4096 -C "me@jonc.dev"
# echo "* Add public key to GitHub:"
# cat "$GITHUB_FILE".pub
# Setup nix with subvolume for /nix
# Build zls from https://github.com/zigtools/zls
