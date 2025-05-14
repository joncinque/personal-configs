# browser.nix: work stuff
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    pkgs.brave
    pkgs.firefox
  ];
}
