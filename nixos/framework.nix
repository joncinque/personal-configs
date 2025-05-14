# laptop.nix: basic laptop config, power management, etc
{ config, pkgs, ... }:
{
  services.power-profiles-daemon.enable = true;
  #services.tlp.enable = true;
  services.fwupd.enable = true;
}
