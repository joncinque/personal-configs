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
      locations."/" = {
        proxyPass = "http://127.0.0.1:12345";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;" +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;"
          ;
      };
    };
    virtualHosts."photos.${domainName}" = {
      forceSSL = true;
      useACMEHost = domainName;
      locations."/" = {
        proxyPass = "http://127.0.0.1:12345";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;" +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;"
          ;
      };
    };
  };
  services.fail2ban.enable = true;

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
