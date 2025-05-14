# python.nix
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    pkgs.python312
    pkgs.pipenv
    pkgs.python312Packages.mypy
    pkgs.python312Packages.pip
    pkgs.python312Packages.pynvim
    pkgs.python312Packages.flake8
    pkgs.python312Packages.python-lsp-server
    pkgs.python312Packages.pylsp-mypy
  ];
}

