#!/usr/bin/env fish

set FUNKWHALE_VERSION "1.0.1"
# Use auto-script

# Replace global nginx settings
sudo curl -L -o /etc/nginx/funkwhale_proxy.conf "https://dev.funkwhale.audio/funkwhale/funkwhale/raw/$FUNKWHALE_VERSION/deploy/funkwhwale_proxy.conf"

# Setup nginx site conf
bash -c 'set -a && source /srv/funkwhale/config/.env && set +a && \
  envsubst "$(env | awk -F = \'{printf " $%s", $$1}\')" \
      < /etc/nginx/sites-available/funkwhale.template \
      > /etc/nginx/sites-available/funkwhale.conf'

ln -s /etc/nginx/sites-available/funkwhale.conf /etc/nginx/sites-enabled/

# Add EMAIL_CONFIG=smtp://localhost:25
sudo vim /srv/funkwhale/config/.env
