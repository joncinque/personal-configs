#! /usr/bin/env fish

# Enable ssh server
# Don't boot into gui
sudo raspi-config
# Create user with sudo
sudo adduser jon
sudo usermod -aG sudo jon
# Relogin and delete pi user
sudo deluser pi
