# piwigo.nix: requirements to run piwigo, NOT the actual server

{ config, pkgs, ... }:
let
  myPhp = pkgs.php.withExtensions ({ enabled, all }: enabled ++ [ all.imagick ]);
in {
  environment.systemPackages = with pkgs; [
    pkgs.ffmpeg
    pkgs.mariadb
    myPhp
    pkgs.imagemagick
  ];
}

