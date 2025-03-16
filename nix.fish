#!/usr/bin/env fish

# Setup a subvolume and mount it
cd /home
sudo btrfs subvolume create nix
sudo btrfs subvolume list . # get ID from command for nix
sudo mount -o subvol=nix /dev/<HOME_DEVICE> /nix
sudo echo "UUID=<HOME_DEVICE_UUID> /nix  btrfs rw,relatime,ssd,discard=async,space_cache=v2,subovlid=<ID>,subvol=nix 0 0" >> /etc/fstab

# Follow the instructions at https://nixos.org/download/, should just work
curl -L https://nixos.org/nix/install -o nix.sh
sh nix.sh --daemon
