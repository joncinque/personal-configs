# postfix.nix: mail transfer setup

{ config, pkgs, ... }:

let
  domainName = "jonc.fun";
  sslCertDir = config.security.acme.certs."${domainName}".directory;
in {
  services.postfix = {
    enable = true;
    enableSubmission = true;
    enableSubmissions = true;

    settings.main = {
      # hostname of mail server, should be fqdn
      myhostname = "mail.${domainName}";
      # domain of the email address that this postfix is hosting
      mydomain = "${domainName}";
      smtpd_tls_cert_file = [ "${sslCertDir}/fullchain.pem" ];
      smtpd_tls_key_file = [ "${sslCertDir}/key.pem" ];
      smtp_tls_cert_file = [ "${sslCertDir}/fullchain.pem" ];
      smtp_tls_key_file = [ "${sslCertDir}/key.pem" ];
    };

    # regexp wildcard: redirect every mail to my account
    virtualMapType = "regexp";
    virtual = ''/.*@.*${domainName}/ me@jonc.dev'';
  };
}
