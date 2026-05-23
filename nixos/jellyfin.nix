# jellyfin.nix: running the server

{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
  services.jellyfin.enable = true;
}

