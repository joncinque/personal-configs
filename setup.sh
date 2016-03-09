#! /usr/bin/env bash

DIR=`dirname $0`
cd $DIR
FULLDIR=`pwd`

# Diff and setup each config
echo "Setting up all config files as symlinks"
for FILE in '.bashrc' '.gitconfig' '.vimrc'
do
  echo "Working on: $FILE"
  if [ -e ~/$FILE ]
  then
    echo "Existing file found, diff:"
    diff ~/$FILE $FULLDIR/$FILE
    rm -i ~/$FILE
  fi
  "Setting up link to $FULLDIR/$FILE"
  ln -s $FULLDIR/$FILE ~
done

echo "Seting up Vundle for vim plugins in .vimrc"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo "Installing extra needed plugins"
cd ~
vim +PluginInstall +qall
