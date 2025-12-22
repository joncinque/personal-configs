# nginx.nix: web server setup

{ config, pkgs, ... }:

let
  domainName = "jonc.fun";
in {
  services.nginx = {
    enable = true;

    # Use recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    clientMaxBodySize = "40m";
    sslProtocols = "TLSv1.3";

    appendHttpConfig = ''
      # Enable CSP for your services.
      # The script-src part doesn't work with Immich, so add 'wasm-unsafe-eval'
      #add_header Content-Security-Policy "default-src https: data: blob: ; img-src 'self' https://* ; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; font-src 'self'";
      add_header Content-Security-Policy "default-src https: data: blob: ; img-src 'self' https://* ; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' 'wasm-unsafe-eval' https://www.gstatic.com https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; font-src 'self'";

      # Minimize information leaked to other domains
      add_header 'Referrer-Policy' 'origin-when-cross-origin';

      # Disable embedding as a frame
      add_header X-Frame-Options DENY;

      # Prevent injection of code in other mime types (XSS Attacks)
      add_header X-Content-Type-Options nosniff;

      # Permissions policy. May cause issues with some clients
      add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), bluetooth=(), camera=(), clipboard-read=(), display-capture=(), document-domain=(), encrypted-media=(), gamepad=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), keyboard-map=(), local-fonts=(), magnetometer=(), microphone=(), payment=(), publickey-credentials-get=(), serial=(), sync-xhr=(), usb=(), xr-spatial-tracking=()" always;

      # This might create errors
      #proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";

      # Increase the maximum size of the hash table
      proxy_headers_hash_max_size 1024;

      # Increase the bucket size of the hash table
      proxy_headers_hash_bucket_size 128;
    '';

    virtualHosts."${domainName}" = {
      forceSSL = true;
      enableACME = true;
    };
    virtualHosts."mail.${domainName}" = {
      forceSSL = true;
      useACMEHost = domainName;
    };
    virtualHosts."music.${domainName}" = {
      forceSSL = true;
      useACMEHost = domainName;
      http2 = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig =
          "proxy_ssl_server_name on;" +
          "proxy_pass_header Authorization;" +
          "proxy_buffering off;"
          ;
      };
      locations."/socket" = {
        # Proxy Jellyfin Websockets traffic
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
    virtualHosts."photos.${domainName}" = {
      forceSSL = true;
      useACMEHost = domainName;
      http2 = true;
      locations."/" = {
        proxyPass = "http://[::1]:${toString config.services.immich.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
      };
    };
  };
  services.fail2ban.enable = true;

  # /var/lib/acme/.challenges must be writable by the ACME user
  # and readable by the Nginx user. The easiest way to achieve
  # this is to add the Nginx user to the ACME group.
  users.users.nginx.extraGroups = [ "acme" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "me@jonc.dev";
    defaults.webroot = "/var/lib/acme/acme-challenge/";

    # We are using nginx as webserver, therefore set correct key permissions
    certs = {
      "${domainName}" = {
        group = config.services.nginx.group;
        extraDomainNames = [
          "mail.${domainName}"
          "music.${domainName}"
          "photos.${domainName}"
        ];
        reloadServices = [
          "nginx"
          "postfix"
        ];
        postRun = ''
          # set permission on dir
          ${pkgs.acl}/bin/setfacl -m \
          u:nginx:rx,u:postfix:rx \
          /var/lib/acme/${domainName}

          # set permission on key file
          ${pkgs.acl}/bin/setfacl -m \
          u:nginx:r,u:postfix:r \
          /var/lib/acme/${domainName}/*.pem
        '';
      };
    };
  };
}
