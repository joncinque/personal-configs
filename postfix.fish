#! /usr/bin/env fish

# Beforehand: setup DNS
# A @.domain.com to IP
# A mail.domain.com to IP
# MX domain.com to mail.domain.com

# Open ports 25 and 587
# Optionally, 80 and 443
set domain "jonc.fun"
set user "jon"
set email "joncinque@pm.me"

sudo echo "$domain" > /etc/mailname
sudo echo "$domain" > /etc/hostname
sudo echo "127.0.1.1 $domain" >> /etc/hosts # remove previous
sudo echo "root: $user" >> /etc/aliases
sudo hostnamectl set-hostname "$domain"

# Install postfix and mailutils
sudo apt install -y postfix mailutils

sudo echo "myhostname = $domain" >> /etc/postfix/main.cf
sudo systemctl restart postfix
sudo newaliases  # propagate aliases

# Setup TLS
sudo apt install -y nginx software-properties-common certbot python3-certbot-nginx
sudo certbot certonly -d "$domain" -m "$email" --agree-tos --standalone --pre-hook='systemctl stop nginx' --post-hook='systemctl start nginx'
sudo echo "server {
    listen 80;

    server_name $domain;
    return 301 https://$domain\$request_uri;
}

server {
    server_name $domain;
    client_max_body_size 75M;
    keepalive_timeout 15;

    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    ssl_session_cache shared:le_nginx_SSL:1m;
    ssl_session_timeout 14400m;
    ssl_protocols TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Deny illegal Host headers
    if (\$host !~* ^($domain|www.$domain)\$) {
        return 444;
    }

    location / {
        proxy_redirect off;
        proxy_pass https://joncinque.github.io;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-HOST \$server_name;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        add_header P3P 'CP=\"ALL DSP COR PSAa PSDa OUR NOR ONL UNI COM NAV\"';
    }
}" > /etc/nginx/sites-enabled/$domain.conf

echo "Getting mail cert"
sudo certbot certonly -d "mail.$domain" -m "$email" --agree-tos --standalone --pre-hook='systemctl stop nginx' --post-hook='systemctl start nginx'

# (Optional, if setting up a server like dovecot) enable TLS submission on Postfix
sudo echo "submission     inet     n    -    y    -    -    smtpd
  -o syslog_name=postfix/submission
  -o smtpd_tls_security_level=encrypt
  -o smtpd_tls_wrappermode=no
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
  -o smtpd_sasl_type=dovecot
  -o smtpd_sasl_path=private/auth" >> /etc/postfix/master.cf

# Setup tls keys for /etc/postfix/main.cf
sudo postconf -e "smtp_tls_cert_file = /etc/letsencrypt/live/mail.$domain/fullchain.pem"
sudo postconf -e "smtp_tls_key_file = /etc/letsencrypt/live/mail.$domain/privkey.pem"
sudo postconf -e "smtpd_tls_cert_file = /etc/letsencrypt/live/mail.$domain/fullchain.pem"
sudo postconf -e "smtpd_tls_key_file = /etc/letsencrypt/live/mail.$domain/privkey.pem"
sudo postconf -e "smtpd_tls_protocols = !SSLv2, !SSLv3"
sudo postconf -e "local_recipient_maps = proxy:unix:passwd.byname \$alias_maps"

# Setup SPF
# https://www.linuxbabe.com/mail-server/setting-up-dkim-and-spf
# Add TXT record in DNS for SPF info
# TXT  @   v=spf1 mx ~all

# Install postfix spf policy checking daemon
sudo apt install -y postfix-policyd-spf-python
# Configure it to start with postfix
sudo echo "policyd-spf  unix  -       n       n       -       0       spawn
  user=policyd-spf argv=/usr/bin/policyd-spf" >> /etc/postfix/master.cf
# Configure postfix to talk to policyd
sudo echo "policyd-spf_time_limit = 3600
smtpd_recipient_restrictions =
    permit_mynetworks,
    permit_sasl_authenticated,
    reject_unauth_destination
    reject_unauth_pipelining,
    reject_unknown_reverse_client_hostname,
    reject_invalid_helo_hostname,
    reject_non_fqdn_helo_hostname,
    reject_non_fqdn_sender,
    reject_non_fqdn_recipient,
    reject_unknown_sender_domain,
    reject_unknown_recipient_domain,
    reject_invalid_hostname,
    reject_rbl_client zen.spamhaus.org,
    reject_rbl_client bl.spamcop.net,
    reject_rbl_client b.barracudacentral.org,
    reject_rbl_client dnsbl.sorbs.net,
    check_policy_service unix:private/policyd-spf
    permit" >> /etc/postfix/main.cf

sudo systemctl restart postfix

# Setup DKIM
sudo apt install -y opendkim opendkim-tools
sudo gpasswd -a postfix opendkim
# Modify after "Commonly-used options..."
sudo echo "Canonicalization       relaxed/simple
AutoRestart         yes
AutoRestartRate     10/1M
Background          yes
DNSTimeout          5
SignatureAlgorithm  rsa-sha256" >> /etc/opendkim.conf

# Add at the end
sudo echo "# Map domains in From addresses to keys used to sign messages
KeyTable           refile:/etc/opendkim/key.table
SigningTable       refile:/etc/opendkim/signing.table

# Hosts to ignore when verifying signatures
ExternalIgnoreList  /etc/opendkim/trusted.hosts

# A set of internal hosts whose mail should be signed
InternalHosts       /etc/opendkim/trusted.hosts" >> /etc/opendkim.conf

# Setup dkim files referenced in opendkim.conf
sudo mkdir -p /etc/opendkim/keys
sudo chown -R opendkim:opendkim /etc/opendkim
sudo chmod go-rw /etc/opendkim/keys
sudo echo "*@$domain    default._domainkey.$domain" > /etc/opendkim/signing.table
sudo echo "default._domainkey.$domain     $domain:default:/etc/opendkim/keys/$domain/default.private" > /etc/opendkim/key.table
sudo echo "127.0.0.1
localhost

*.$domain" > /etc/opendkim/trusted.hosts

# Generate dkim keys
sudo mkdir -p /etc/opendkim/keys/$domain
sudo opendkim-genkey -b 2048 -d $domain -D /etc/opendkim/keys/$domain -s default -v
sudo chown opendkim:opendkim /etc/opendkim/keys/$domain/default.private

# Add TXT record in DNS for the public key containing info from /etc/opendkim/keys/$domain/default.txt
# TXT default._domainkey v=DKIM1; h=sha256......

# Test key
sudo opendkim-testkey -d $domain -s default -vvv

# Connecting postfix to DKIM
sudo mkdir /var/spool/postfix/opendkim
sudo chown opendkim:postfix /var/spool/postfix/opendkim

# Replace Socket in /etc/opendkim.conf to local:/var/spool/postfix/opendkim/opendkim.sock
sudo vim /etc/opendkim.conf
# Replace Socket in /etc/default/opendkim to local:/var/spool/postfix/opendkim/opendkim.sock
sudo vim /etc/default/opendkim

# Add to postfix config
sudo echo "# Milter configuration
milter_default_action = accept
milter_protocol = 6
smtpd_milters = local:/opendkim/opendkim.sock
non_smtpd_milters = \$smtpd_milters" >> /etc/postfix/main.cf

sudo systemctl restart opendkim postfix

# Updates to avoid spamming and retrying too much
# https://jrs-s.net/2013/04/17/configuring-retry-duration-in-postfix/
sudo echo "# if you can't deliver it in an hour - it can't be delivered!
maximal_queue_lifetime = 1h
maximal_backoff_time = 15m
minimal_backoff_time = 5m
queue_run_delay = 5m" >> /etc/postfix/main.cf

# Setting up DMARC
# https://www.linuxbabe.com/mail-server/opendmarc-postfix-ubuntu
# choose "no" for db config
sudo apt install -y opendmarc
sudo systemctl enable opendmarc

# DMARC config file
sudo echo "AuthservID OpenDMARC" >> /etc/opendmarc.conf
sudo echo "TrustedAuthservIDs mail.$domain" >> /etc/opendmarc.conf
sudo echo "RejectFailures false" >> /etc/opendmarc.conf
sudo echo "IgnoreAuthenticatedClients true" >> /etc/opendmarc.conf
sudo echo "RequiredHeaders true" >> /etc/opendmarc.conf
sudo echo "SPFSelfValidate true" >> /etc/opendmarc.conf
sudo echo "Socket local:/var/spool/postfix/opendmarc/opendmarc.sock" >> /etc/opendmarc.conf

# Add socket and permissions for postfix
sudo mkdir -p /var/spool/postfix/opendmarc
sudo chown opendmarc:opendmarc /var/spool/postfix/opendmarc -R
sudo chmod 750 /var/spool/postfix/opendmarc/ -R
sudo adduser postfix opendmarc
sudo systemctl restart opendmarc

# Add opendmarc socket to milters in postfix
# sudo echo "smtpd_milters = local:/opendkim/opendkim.sock,local:opendmarc/opendmarc.sock" >> /etc/postfix/main.cf
sudo vim /etc/postfix/main.cf
sudo systemctl restart postfix

# Add DNS TXT record for DMARC info, start with "none" and work up to "quarantine" and "reject"
# _dmarc.$domain
# v=DMARC1; p=none; pct=100; rua=mailto:dmarc@$domain

# Setting up virtual addresses
sudo echo "virtual_alias_domains = $domain
virtual_alias_maps = hash:/etc/postfix/virtual" >> /etc/postfix/main.cf

sudo echo "@$domain $email" > /etc/postfix/virtual
sudo postmap /etc/postfix/virtual

sudo postfix reload

# Check with https://www.mail-tester.com/ for score
# Check with https://www.wormly.com/test-smtp-server

echo "Setting up Dovecot IMAP server with SASL"
sudo apt install -y dovecot-core dovecot-imapd
sudo cp /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.dist
sudo echo "disable_plaintext_auth = no
mail_home = /srv/mail/%Lu
mail_location = sdbox:~/mail
userdb {
  driver = passwd
  args = blocking=no
}
passdb {
  args = %s
  driver = pam
}
protocols = imap
service auth {
  unix_listener /var/spool/postfix/private/auth {
    group = postfix
    mode = 0660
    user = postfix
  }
}
auth_mechanisms = plain login
ssl = required
ssl_cert = </etc/letsencrypt/live/mail.$domain/fullchain.pem
ssl_key = </etc/letsencrypt/live/mail.$domain/privkey.pem" > /etc/dovecot/dovecot.conf
sudo systemctl restart dovecot
