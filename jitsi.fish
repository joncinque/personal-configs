#!/usr/bin/env fish

# Adapted from https://www.digitalocean.com/community/tutorials/how-to-install-jitsi-meet-on-ubuntu-18-04

set domain "meet.jonc.fun"
set user "jon"
set password "something_secure"

# Install Jitsi meet
wget https://download.jitsi.org/jitsi-key.gpg.key
sudo apt-key add jitsi-key.gpg.key
rm jitsi-key.gpg.key
echo "deb https://download.jitsi.org stable/" | sudo tee /etc/apt/sources.list.d/jitsi-stable.list
sudo apt update
sudo apt install jitsi-meet

# Use your desired URL

# Setup TLS certificate
sudo add-apt-repository ppa:certbot/certbot
sudo apt install certbot
sudo /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh

# Update authentication from "anonymous" to "internal_plain"
sudo vim /etc/prosody/conf.avail/"$domain".cfg.lua
echo "VirtualHost \"guest.$domain\"
    authentication = \"anonymous\"
    c2s_require_encryption = false" | sudo tee -a /etc/prosody/conf.avail/"$domain".cfg.lua

# Update anonymousdomain to guest.$domain in js config
sudo vim /etc/jitsi/meet/"$domain"-config.js

# Update communicator
echo "org.jitsi.jicofo.auth.URL=XMPP:$domain" | sudo tee -a /etc/jitsi/jicofo/sip-communicator.properties

# Add authenticated user
sudo prosodyctl register $user $domain $password

# Restart everything
sudo systemctl restart prosody
sudo systemctl restart jicofo
sudo systemctl restart jitsi-videobridge2
