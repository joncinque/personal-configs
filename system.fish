#!/usr/bin/env fish
# Swap files
echo '* sysctl updates'
echo '** file descriptors'
echo 'fs.file-max = 500000' | sudo tee -a /etc/sysctl.conf
echo 'fs.inotify.max_user_watches = 524288' | sudo tee -a /etc/sysctl.conf

echo '* propagate changes'
sudo sysctl -p

# echo '* check number of open files'
# lsof | wc -l
