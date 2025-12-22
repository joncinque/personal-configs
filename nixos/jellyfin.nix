# jellyfin.nix: running the server

{ config, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
  services.jellyfin.enable = true;
}

