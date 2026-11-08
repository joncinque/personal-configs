# browser.nix: work stuff
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    ungoogled-chromium
    firefox
  ];
}
