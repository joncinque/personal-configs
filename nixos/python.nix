# python.nix
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    python3
  ];
}

