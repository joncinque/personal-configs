# steam.nix
{ config, pkgs, ...}:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remoteplay
    dedicatedServer.openFirewall = true; # Open ports in the firewall for steam server
  };
  # Install whatever else is needed through lutris
  environment.systemPackages = with pkgs; [
    lutris-free
  ];
}
