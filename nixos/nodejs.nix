# nodejs.nix: node stuff
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    nodenv
    nodejs_22
    typescript
  ];
}
