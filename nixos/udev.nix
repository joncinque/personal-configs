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

  # trezor-udev-rules assumes there's a `trezord` group, which comes with the
  # `trezord` package, which we don't install
  users.groups.trezord = { };
}
