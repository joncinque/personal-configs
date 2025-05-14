# nodejs.nix: node stuff
{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    pkgs.nodenv
    #pkgs.nodejs_20
    pkgs.nodejs_22
    pkgs.typescript
  ];
}
