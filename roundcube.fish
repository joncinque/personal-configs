#!/usr/bin/env fish

set domain "jonc.fun"
set mail_domain mail.$domain

echo "* Installing prerequisites"
supo apt install -y php php-fpm php-mbstring php-dom php-curl php-sqlite3 php-intl php-zip php-gd php-imagick sqlite3

echo "* Update php.ini with https://github.com/roundcube/roundcubemail/wiki/Installation#php-configuration"
sudo vim /etc/php/*/fpm/php.ini

echo "* Install composer"
function install_composer
  set EXPECTED_CHECKSUM (php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  set ACTUAL_CHECKSUM (php -r "echo hash_file('sha384', 'composer-setup.php');")

  if test "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM"
    echo "ERROR: Invalid installer checksum"
    rm composer-setup.php
    exit 1
  end

  php composer-setup.php --quiet
  set RESULT $status
  rm composer-setup.php
  exit $RESULT
end
install_composer

echo "* Fetch source"
set VERSION 1.6.2
set ROUNDCUBE_URL https://github.com/roundcube/roundcubemail/releases/download/$VERSION/roundcubemail-$VERSION.tar.gz
curl -L -O $ROUNDCUBE_URL
tar xfz roundcubemail-$VERSION.tar.gz

echo "* Install PHP and JS dependencies"
cd roundcubemail-$VERSION
mv composer.json-dist composer.json
composer install --no-dev
./bin/install-jsdeps.sh

echo "* Setup nginx file"
echo "server {
  listen 80;
  listen [::]:80;

  location ~ /.well-known {
    allow all;
  }

  server_name $mail_domain;
  return 301 https://$mail_domain\$request_uri;
}

server {
  listen 443 ssl;
  listen [::]:443 ssl;
  server_name $mail_domain;
  root /var/www/roundcubemail/;
  index index.php index.html index.htm;

  client_max_body_size 75M;
  keepalive_timeout 15;

  ssl_certificate /etc/letsencrypt/live/$mail_domain/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$mail_domain/privkey.pem;
  ssl_session_cache shared:le_nginx_SSL:1m;
  ssl_session_timeout 14400m;
  ssl_protocols TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_ciphers HIGH:!aNULL:!MD5;

  error_log /var/log/nginx/roundcube.error;
  access_log /var/log/nginx/roundcube.access;

  # Deny illegal Host headers
  if (\$host !~* ^($mail_domain|www.$mail_domain)\$) {
    return 444;
  }

  location / {
    try_files \$uri \$uri/ /index.php;
  }

  location ~ \\.php\$ {
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
  location ~* \\.(jpg|jpeg|gif|png|webp|svg|woff|woff2|ttf|css|js|ico|xml)\$ {
       access_log        off;
       log_not_found     off;
       expires           360d;
  }
}" > /etc/nginx/sites-available/$mail_domain.conf
sudo ln -s /etc/nginx/sites-available/$mail_domain.conf /etc/nginx/sites-enabled
cd ..
sudo cp -R roundcubemail-$VERSION /var/www/roundcubemail

echo "Done. Please go to https://$mail_domain/installer"
