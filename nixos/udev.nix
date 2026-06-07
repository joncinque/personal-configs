# udev.nix: additional udev rules for devices
{ config, pkgs, ...}:
let
  keystoneUdevRules = pkgs.callPackage ./keystone-udev-rules/package.nix { inherit pkgs; };
in
{
  services.udev.packages = with pkgs; [
      ledger-udev-rules
      trezor-udev-rules
      keystoneUdevRules
      # potentially even more if you need them
  ];
}
