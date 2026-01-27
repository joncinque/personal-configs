# python.nix
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    pkgs.python313
    pkgs.python313Packages.flake8
    pkgs.python313Packages.magic
    pkgs.python313Packages.mypy
    pkgs.python313Packages.pip
    pkgs.python313Packages.pynvim
    pkgs.python312Packages.python-lsp-server
    pkgs.python313Packages.pylsp-mypy
    pkgs.python313Packages.uv
    pkgs.python313Packages.ujson
  ];
}

