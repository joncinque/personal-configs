# docker.nix: install and configure
{ pkgs, ... }:
{
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  # Enable with $ systemctl --user enable --now docker

  # For Claude
  environment.systemPackages = with pkgs; [
    devcontainer
  ];

  # Follow instructions at https://github.com/trailofbits/claude-code-devcontainer
  # for `devc` command
}

