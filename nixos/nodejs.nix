# nodejs.nix: node stuff
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    nodejs
    typescript
  ];
}
