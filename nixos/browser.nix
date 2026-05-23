# browser.nix: work stuff
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    brave
    firefox
  ];
}
