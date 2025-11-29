# funkwhale.nix: requirements to run funkwhale, NOT the actual server

{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pkgs.ffmpeg
    pkgs.file
    pkgs.libjpeg
    pkgs.libpqxx
    pkgs.openldap
    pkgs.cyrus_sasl # or gsasl?
  ];
  users.users.funkwhale = {
    isNormalUser = true;
    createHome = true;
    home = "/srv/funkwhale";
    shell = "/run/current-system/sw/bin/bash";
  };
}
