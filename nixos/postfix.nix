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
      myhostname = "${domainName}";
      smtpd_tls_cert_file = [ "${sslCertDir}/fullchain.pem" ];
      smtpd_tls_key_file = [ "${sslCertDir}/key.pem" ];
      smtpd_tls_security_level = "encrypt";
      smtp_tls_cert_file = [ "${sslCertDir}/fullchain.pem" ];
      smtp_tls_key_file = [ "${sslCertDir}/key.pem" ];
      smtp_tls_security_level = "encrypt";
    };

    # regexp wildcard: redirect every mail to my account
    virtualMapType = "regexp";
    virtual = ''/.*@.*${domainName}/ me@jonc.dev'';
  };
}
