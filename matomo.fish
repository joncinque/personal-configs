#! /usr/bin/env fish

set domain "matomo.jonc.dev"
set user "jon"
set email "me@jonc.dev"
set location "/var/www/matomo"
set dbuser "jon"
set dbpassword "mypassword"
set dbname "matomo_analytics"

echo "Setting up mysql"
sudo apt install -y mysql-server
sudo mysql_secure_installation
# be sure to have a root password chosen
sudo mysql < "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpassword';"
sudo mysql < "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';"


echo "Getting cert for matomo installation"
sudo certbot certonly -d "$domain" -m "$email" --agree-tos --standalone --pre-hook='systemctl stop nginx' --post-hook='systemctl start nginx'

echo "Fetching Matomo build"
wget https://builds.matomo.org/matomo.zip && unzip matomo.zip
sudo cp -r matomo $location
echo "Making /var/www accessible to www-data"
sudo chown www-data:www-data -R /var/www

echo "Setting up nginx config for matomo"
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
    if (\$host !~* ^($domain|www.$domain)$) {
        return 444;
    }

    root /var/www/matomo/;
    index index.php;

    ## only allow accessing the following php files
    location ~ ^/(index|matomo|piwik|js/index|plugins/HeatmapSessionRecording/configs)\.php {
        include snippets/fastcgi-php.conf; # if your Nginx setup doesn't come with a default fastcgi-php config, you can fetch it from https://github.com/nginx/nginx/blob/master/conf/fastcgi.conf
        # try_files $fastcgi_script_name =404; # protects against CVE-2019-11043. If this line is already included in your snippets/fastcgi-php.conf you can comment it here.
        fastcgi_param HTTP_PROXY ""; # prohibit httpoxy: https://httpoxy.org/
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock; #replace with the path to your PHP socket file
        #fastcgi_pass 127.0.0.1:9000; # uncomment if you are using PHP via TCP sockets (e.g. Docker container)
    }

    ## deny access to all other .php files
    location ~* ^.+\.php$ {
        deny all;
        return 403;
    }

    ## serve all other files normally
    location / {
      try_files $uri $uri/ =404;
    }

    ## disable all access to the following directories
    location ~ ^/(config|tmp|core|lang) {
      deny all;
      return 403; # replace with 404 to not show these directories exist
    }

    location ~ /\.ht {
      deny  all;
      return 403;
    }

    location ~ js/container_.*_preview\.js$ {
      expires off;
      add_header Cache-Control 'private, no-cache, no-store';
    }

    location ~ \.(gif|ico|jpg|png|svg|js|css|htm|html|mp3|mp4|wav|ogg|avi|ttf|eot|woff|woff2|json)$ {
      allow all;
      ## Cache images,CSS,JS and webfonts for an hour
      ## Increasing the duration may improve the load-time, but may cause old files to show after an Matomo upgrade
      expires 1h;
      add_header Pragma public;
      add_header Cache-Control "public";
    }

    location ~ ^/(libs|vendor|plugins|misc/user) {
      deny all;
      return 403;
    }

    ## properly display textfiles in root directory
    location ~/(.*\.md|LEGALNOTICE|LICENSE) {
      default_type text/plain;
    }
}" > /etc/nginx/sites-enabled/$domain.conf
sudo apt install -y php7.2-fpm php7.2-mbstring php7.2-mysql php7.2-dom php7.2-xml
sudo systemctl start php7.2-fpm
sudo systemctl enable php7.2-fpm
sudo systemctl restart nginx

echo "Go to $domain to configure installation, using db info configured earlier, then add js code wherever needed!"

# Sample requirement on webpage
# <script type="text/javascript">
#   var _paq = _paq || [];
#   /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
#   _paq.push(['trackPageView']);
#   _paq.push(['enableLinkTracking']);
#   (function() {
#     var u="//{{- site.matomo.uri -}}/";
#     _paq.push(['setTrackerUrl', u+'matomo.php']);
#     _paq.push(['setSiteId', '{{- site.matomo.site_id -}}']);
#     var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
#     g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
#   })();
# </script>
#
# for opt-out capabilities, add:
# <a href="http://{{- site.matomo.uri -}}/index.php?module=CoreAdminHome&action=optOut" target="_blank" class="text_muted">Do not track</a>
#
