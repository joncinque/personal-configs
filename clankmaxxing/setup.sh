#!/usr/bin/env bash

DIR=$(pwd)
# Create dir and configs
mkdir ~/src/clankmaxxing
ln -s ${DIR}/gitconfig ~/src/clankmaxxing/gitconfig
ln -s ${DIR}/flake.nix ~/src/clankmaxxing/flake.nix

# Create `workspace` directory
mkdir ~/src/clankmaxxing/workspace

# SSH keys
mkdir ~/src/clankmaxxing/ssh
echo "Get ssh keys, put in ssh directory"

# Get claude-code-devcontainer
git clone git@github.com:joncinque/claude-code-devcontainer.git
ln -s ${DIR}/claude-code-devcontainer ~/.claude-devcontainer
cd claude-code-devcontainer
bash ./install.sh
