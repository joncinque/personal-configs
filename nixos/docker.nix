# docker.nix: install and configure
{ pkgs, ... }:
{
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  # Enable with $ systemctl --user enable --now docker
}

