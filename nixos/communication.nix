# communication.nix: work stuff
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    #discord not free, use the web version anyway
    #slack not free, use the web version
    #telegram-desktop, use the web version
    signal-desktop
  ];
}

