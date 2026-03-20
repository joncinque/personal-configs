#!/usr/bin/env bash

# Install basics as root: sudo, git
#apt install sudo git
# Add user to sudoers
sudo adduser jon
sudo usermod -aG sudo jon

name="iggy"
echo $name | sudo tee /etc/hostname
echo "EDIT /etc/hosts TO ADD NAME"

# Partition disk + mkfs.ext4 + fstab
sudo apt install -y parted
sudo parted /dev/nvme0n1 # /data /accounts /data2 /ledger
# mktable gpt
# mkpart <NAME> ext4 1049kB 300GB
# mkpart <NAME> ext4 300GB 1920GB
sudo mkfs.ext4 /dev/nvme0n1p1
sudo mkfs.ext4 /dev/nvme0n1p2
sudo mkfs.ext4 /dev/nvme1n1p1
sudo mkfs.ext4 /dev/nvme1n1p2
echo "# /data
/dev/nvme0n1p1   /data  ext4   defaults    0   0
# /accounts
/dev/nvme0n1p2   /accounts  ext4   defaults    0   0

# /data2
/dev/nvme1n1p1   /data2  ext4   defaults    0   0
# /ledger
/dev/nvme1n1p2   /ledger  ext4   defaults    0   0" | sudo tee -a /etc/fstab

sudo mkdir /data /ledger /data2 /accounts
sudo mount -a

# Run setup script
mkdir -p src
cd src
git clone https://github.com/joncinque/personal-configs
cd personal-configs
./setup.sh

# Add val user
sudo adduser val
sudo usermod -aG val jon
sudo chmod g+w -R /home/val

# Build with nixpkgs
VERSION="v4.0"
cd ~/src
git clone https://github.com/joncinque/nixpkgs/ --depth 1 -b jito-${VERSION}
cd nixpkgs
NIXPKGS=. nix-build $NIXPKGS -A jito-solana
cp -R result /home/val/${VERSION}
ln -s /home/val/${VERSION} /home/val/active-release

echo "fish_add_path /home/val/active-release/bin" >> ~/.config/fish/config.fish

# Copy scripts
cp -R scripts /home/val

# Add systemd
echo "[Unit]
Description=Solana Validator
After=network.target
Wants=network-online.target
StartLimitIntervalSec=0

[Service]
Type=simple
User=val
Group=val
Restart=no
LimitNOFILE=2000000
LimitNPROC=2000000
LimitCORE=infinity
LimitMEMLOCK=2000000000
ExecStart=/home/val/scripts/validator.sh
TimeoutStopSec=infinity
ExecStop=/home/val/active-release/bin/agave-validator exit --skip-health-check --max-delinquent-stake 5
AmbientCapabilities=CAP_NET_RAW CAP_NET_ADMIN CAP_BPF CAP_PERFMON

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/val.service

# Systuning in security/limits.d and systemd and sysctl
echo "# Increase max UDP buffer sizes
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728

# Increase memory mapped files limit
vm.max_map_count = 2000000

# Increase number of allowed open file descriptors
fs.nr_open = 2000000" | sudo tee /etc/sysctl.d/21-agave-validator.conf
sudo sysctl -p /etc/sysctl.d/21-agave-validator.conf

echo "# Increase process file descriptor count limit
* - nofile 2000000
# Increase memory locked limit (kB)
* - memlock 2000000000" | sudo tee /etc/security/limits.d/90-validator-nofiles.conf

# Add journal turnaround
echo "/data2/agave-validator.log {
    daily
    copytruncate
    rotate 7
    create 640 val val
}" | sudo tee -a /etc/logrotate.conf
sudo logrotate --verbose -f /etc/logrotate.conf

# ufw
sudo ufw allow 8000:10000/udp
sudo ufw allow 8000:10000/tcp

echo "Create links for service-env.sh and jito-env.sh"
ln -s /home/val/scripts/jito-env-mainnet.sh /home/val/scripts/jito-env.sh
ln -s /home/val/scripts/service-env-mainnet.sh /home/val/scripts/service-env.sh

echo "Setup alloy service for Grafana"
echo "Copy identity key to machine"
echo "Start val.service"
