# communication.nix: work stuff
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    #discord not free, use the web version anyway
    #slack not free
    signal-desktop
    telegram-desktop
  ];
}

