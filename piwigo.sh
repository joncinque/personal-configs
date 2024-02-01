#!/usr/bin/env bash

domain="photos.domain.com"

echo "Installing base php requirements, may need to be updated"
sudo apt install -y php8.2-fpm php8.2-common php8.2-mbstring php8.2-xmlrpc php8.2-gd php8.2-xml php8.2-intl php8.2-mysql php8.2-cli php8.2 php8.2-ldap php8.2-zip php8.2-curl

echo "Be sure to set the following:
file_uploads = On
allow_url_fopen = On
memory_limit = 256M
post_max_size = 128M
upload_max_filesize = 128M"
sudo vim /etc/php/8.2/fpm/php.ini

echo "Installing mariadb to store photos"
sudo apt install -y mariadb-server

echo "Setup database basics"
sudo mysql_secure_installation

echo "Create database"
echo "CREATE DATABASE piwigo;
CREATE USER 'piwigouser'@'localhost' IDENTIFIED BY 'new_password_here';
GRANT ALL ON piwigo.* TO 'piwigouser'@'localhost' IDENTIFIED BY 'user_password_here' WITH GRANT OPTION;
FLUSH PRIVILEGES;" | sudo mysql


echo "Fetching piwigo code"
cd /tmp && curl -o piwigo.zip http://piwigo.org/download/dlcounter.php?code=latest
unzip piwigo.zip
sudo mv piwigo /var/www/html/piwigo
sudo chown -R www-data:www-data /var/www/html/piwigo/
sudo chmod -R 755 /var/www/html/piwigo/
sudo systemctl restart nginx.service

echo "server {
  listen 80;
  listen [::]:80;

  location ~ /.well-known {
    allow all;
  }

  server_name $domain;
  return 301 https://${domain}\$request_uri;
}

server {
  listen 443 ssl;
  listen [::]:443 ssl;
  server_name $domain;
  root /var/www/html/piwigo/;
  index index.php index.html index.htm;

  client_max_body_size 128M;
  keepalive_timeout 15;

  ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
  ssl_session_cache shared:le_nginx_SSL:10m;
  ssl_session_timeout 14400m;
  ssl_protocols TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_ciphers HIGH:!aNULL:!MD5;

  error_log /var/log/nginx/piwigo.error;
  access_log /var/log/nginx/piwigo.access;

  # Deny illegal Host headers
  if (\$host !~* ^($domain|www.$domain)\$) {
    return 444;
  }

  location / {
    try_files \$uri \$uri/ /index.php;
  }

  location ~ \.php\$ {
    try_files \$uri =404;
    fastcgi_pass unix:/run/php/php-fpm.sock;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    include fastcgi_params;
  }

  location ~ /.well-known {
    allow all;
  }
  location ~ ^/(README|INSTALL|LICENSE|CHANGELOG|UPGRADING)\$ {
    deny all;
  }
  location ~ ^/(bin|SQL)/ {
    deny all;
  }
  # A long browser cache lifetime can speed up repeat visits to your page
  location ~* \.(jpg|jpeg|gif|png|webp|svg|woff|woff2|ttf|css|js|ico|xml)\$ {
       access_log        off;
       log_not_found     off;
       expires           360d;
  }
}" | sudo tee /etc/nginx/sites-available/piwigo.conf
sudo ln -s /etc/nginx/sites-available /etc/nginx/sites-enabled

echo "Generating certs"
sudo certbot --nginx -d $domain

echo "All done on this side! Please go to https://$domain to set everything up!"
