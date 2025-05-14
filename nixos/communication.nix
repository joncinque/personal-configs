# communication.nix: work stuff
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    #pkgs.discord not free, use the web version anyway
    #pkgs.slack not free
    pkgs.signal-desktop
    pkgs.telegram-desktop
  ];
}

