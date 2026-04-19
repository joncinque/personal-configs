# python.nix
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    pkgs.python3
  ];
}

